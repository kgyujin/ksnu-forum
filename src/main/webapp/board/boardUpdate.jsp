<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

    int postId = 0;
    int boardId = 0;
    String title = "";
    String content = "";

    // 게시글 ID와 게시판 ID 가져오기
    try {
        postId = Integer.parseInt(request.getParameter("postId"));
        boardId = Integer.parseInt(request.getParameter("boardId"));
    } catch (NumberFormatException e) {
        out.println("<p>올바르지 않은 접근입니다. 게시글 번호 또는 게시판 번호가 없습니다.</p>");
        return;
    }

    // 기존 게시글 불러오기
    if ("GET".equalsIgnoreCase(request.getMethod())) {
        try {
            String postSql = "SELECT TITLE, CONTENT FROM POSTS WHERE POST_ID = ?";
            PreparedStatement postStmt = conn.prepareStatement(postSql);
            postStmt.setInt(1, postId);
            ResultSet postRs = postStmt.executeQuery();

            if (postRs.next()) {
                title = postRs.getString("TITLE");
                content = postRs.getString("CONTENT");
            } else {
                out.println("<p>게시글을 찾을 수 없습니다.</p>");
                return;
            }
            postRs.close();
            postStmt.close();
        } catch (Exception e) {
            out.println("오류: " + e.getMessage());
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>게시글 수정</title>
    <meta charset="UTF-8">
    <style>
        .form-container {
            width: 50%;
            margin: 20px auto;
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 5px;
        }
        .form-container h2 {
            text-align: center;
        }
        .form-field {
            margin: 10px 0;
        }
        input, textarea, button {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            box-sizing: border-box;
        }
        .thumbnail {
            width: 100px;
            height: 100px;
            object-fit: cover;
            margin: 5px;
        }
        .button-group {
            text-align: center;
        }
        button {
            width: 45%;
            margin: 5px;
        }
    </style>
</head>
<body>

<div class="form-container">
    <h2>게시글 수정</h2>
    <form method="post" enctype="multipart/form-data" action="/board/updatePost.jsp">
        <div class="form-field">
            <label>제목 (최대 100자):</label>
            <input type="text" name="title" maxlength="100" required value="<%= title %>">
        </div>
        <div class="form-field">
            <label>내용 (최대 2000자):</label>
            <textarea name="content" maxlength="2000" required><%= content %></textarea>
        </div>

        <!-- 기존 이미지 표시 -->
        <div class="form-field">
            <label>기존 이미지:</label>
            <%
                String imgSql = "SELECT IMAGE_ID, IMAGE_PATH FROM post_images WHERE POST_ID = ?";
                PreparedStatement imgStmt = conn.prepareStatement(imgSql);
                imgStmt.setInt(1, postId);
                ResultSet imgRs = imgStmt.executeQuery();
                while (imgRs.next()) {
                    int imageId = imgRs.getInt("IMAGE_ID");
                    String imagePath = imgRs.getString("IMAGE_PATH");
            %>
                <div>
                    <img src="<%= request.getContextPath() + "/" + imagePath %>" alt="이미지" class="thumbnail">
                    <label>
                        <input type="checkbox" name="deleteImage" value="<%= imageId %>"> 삭제
                    </label>
                </div>
            <%
                }
                imgRs.close();
                imgStmt.close();
            %>
        </div>

        <!-- 새 이미지 업로드 -->
        <div class="form-field">
            <label>새 이미지 추가 (최대 4개):</label>
            <input type="file" name="images" multiple accept="image/*">
        </div>

        <div class="button-group">
            <button type="submit">수정</button>
            <button type="button" onclick="location.href='/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>'">취소</button>
        </div>

        <input type="hidden" name="boardId" value="<%= boardId %>">
        <input type="hidden" name="postId" value="<%= postId %>">
    </form>
</div>

</body>
</html>
