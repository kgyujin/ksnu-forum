<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ page import="com.ksnu.service.PostService" %>

<%
    // 로그인 여부 확인
    Object userIdObj = session.getAttribute("userId");
    if (userIdObj == null) {
        response.sendRedirect("/login.jsp");
        return;
    }

    try {
        userId = Integer.parseInt(userIdObj.toString());
    } catch (NumberFormatException e) {
        out.println("<p>유효하지 않은 사용자입니다. 다시 로그인 해주세요.</p>");
        return;
    }

    int postId = 0;
    int boardId = 0;
	
    // 게시글 ID와 게시판 ID 가져오기
    try {
        postId = Integer.parseInt(request.getParameter("postId"));
        boardId = Integer.parseInt(request.getParameter("boardId"));
    } catch (NumberFormatException e) {
        out.println("<p>올바르지 않은 접근입니다. 게시글 번호 또는 게시판 번호가 없습니다.</p>");
        return;
    }

    // 게시글 삭제 처리
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            // 1. 이미지 경로 조회
            String getImageSql = "SELECT IMAGE_PATH FROM post_images WHERE POST_ID = ?";
            PreparedStatement getImageStmt = conn.prepareStatement(getImageSql);
            getImageStmt.setInt(1, postId);
            ResultSet rs = getImageStmt.executeQuery();

            while (rs.next()) {
                String imagePath = rs.getString("IMAGE_PATH");
                String absolutePath = application.getRealPath("/") + imagePath;

                // 2. 이미지 파일 삭제
                File file = new File(absolutePath);
                if (file.exists()) {
                    if (file.delete()) {
                        out.println("<p>이미지 파일 삭제 성공: " + imagePath + "</p>");
                    } else {
                        out.println("<p>이미지 파일 삭제 실패: " + imagePath + "</p>");
                    }
                }
            }

            rs.close();
            getImageStmt.close();

            // 3. 이미지 DB 정보 삭제
            String deleteImageSql = "DELETE FROM post_images WHERE POST_ID = ?";
            PreparedStatement deleteImageStmt = conn.prepareStatement(deleteImageSql);
            deleteImageStmt.setInt(1, postId);
            deleteImageStmt.executeUpdate();
            deleteImageStmt.close();
            
         	// 스크랩 정보 삭제
            String deleteScrapsSql = "DELETE FROM scraps WHERE POST_ID = ?";
            PreparedStatement deleteScrapsStmt = conn.prepareStatement(deleteScrapsSql);
            deleteScrapsStmt.setInt(1, postId);
            deleteScrapsStmt.executeUpdate();
            deleteScrapsStmt.close();
            
         	// 추천 정보 삭제
            String deleteRecommendsSql = "DELETE FROM recommends WHERE POST_ID = ?";
            PreparedStatement deleteRecommendsStmt = conn.prepareStatement(deleteRecommendsSql);
            deleteRecommendsStmt.setInt(1, postId);
            deleteRecommendsStmt.executeUpdate();
            deleteRecommendsStmt.close();

         	// 댓글 삭제 SQL
            String deleteCommentsSql = "DELETE FROM comments WHERE POST_ID = ?";
            PreparedStatement deleteCommentsStmt = conn.prepareStatement(deleteCommentsSql);
            deleteCommentsStmt.setInt(1, postId);
            deleteCommentsStmt.executeUpdate();
            deleteCommentsStmt.close();
            
            // 4. 게시글 삭제 SQL
            String deletePostSql = "DELETE FROM POSTS WHERE POST_ID = ? AND USER_ID = ?";
            PreparedStatement deletePostStmt = conn.prepareStatement(deletePostSql);
            deletePostStmt.setInt(1, postId);
            deletePostStmt.setInt(2, userId);

            int result = deletePostStmt.executeUpdate();
            deletePostStmt.close();

            if (result > 0) {
                response.sendRedirect("/board/boardList.jsp?boardId=" + boardId);
            } else {
                out.println("<p>게시글 삭제에 실패했습니다.</p>");
            }
        } catch (Exception e) {
            out.println("삭제 오류: " + e.getMessage());
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>게시글 삭제</title>
    <meta charset="UTF-8">
    <style>
        .form-container {
            width: 50%;
            margin: 20px auto;
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .form-container h2 {
            text-align: center;
            color: #c94c00;
        }
        .form-field {
            margin: 10px 0;
            text-align: center;
            font-size: 16px;
            color: #333;
        }
        .button-group {
            text-align: center;
        }
        button {
            width: 45%;
            margin: 5px;
            padding: 10px;
            border: none;
            background-color: #20409a;
            color: #fff;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover {
            background-color: #c94c00;
        }
        .cancel-button {
            background-color: #aaa;
        }
    </style>
</head>
<body>

<div class="form-container">
    <h2>게시글 삭제</h2>
    <div class="form-field">
        <p>정말로 이 게시글을 삭제하시겠습니까?</p>
    </div>
    <form method="post">
        <div class="button-group">
            <button type="submit">삭제</button>
            <button type="button" class="cancel-button" 
                    onclick="location.href='/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>'">취소</button>
        </div>
        <input type="hidden" name="boardId" value="<%= boardId %>">
        <input type="hidden" name="postId" value="<%= postId %>">
    </form>
</div>

</body>
</html>
