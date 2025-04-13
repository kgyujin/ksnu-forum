<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ page import="com.ksnu.service.PostService" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.io.File" %>

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
    } catch (NumberFormatException nfe1) {
        out.println("<p>잘못된 게시글 또는 게시판 ID입니다.</p>");
        return;
    }

    // POST 요청 처리 - 게시글 수정
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            title = request.getParameter("title");
            content = request.getParameter("content");
            String[] deleteImages = request.getParameterValues("deleteImage");
            
            if (title != null && content != null) {
                // 게시글 정보 업데이트
                boolean isSuccess = PostService.updatePost(conn, postId, title, content);
                
                if (!isSuccess) {
                    out.println("<p>게시글 수정에 실패했습니다.</p>");
                    return;
                }
                
                // 이미지 삭제 처리
				if (deleteImages != null) {
				    String selectSql = "SELECT IMAGE_PATH FROM post_images WHERE IMAGE_ID = ?";
				    String deleteSql = "DELETE FROM post_images WHERE IMAGE_ID = ?";
				    PreparedStatement selectStmt = conn.prepareStatement(selectSql);
				    PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
				
				    for (String imageId : deleteImages) {
				        int imgId = Integer.parseInt(imageId);
				
				        // 실제 이미지 파일 경로 조회 및 삭제
				        selectStmt.setInt(1, imgId);
				        ResultSet rs = selectStmt.executeQuery();
				        if (rs.next()) {
				            String imagePath = rs.getString("IMAGE_PATH");
				            if (imagePath != null && !imagePath.trim().isEmpty()) {
				                File imageFile = new File(application.getRealPath("/") + imagePath);
				                if (imageFile.exists()) {
				                    imageFile.delete();
				                }
				            }
				        }
				        rs.close();
				
				        // DB에서 이미지 삭제
				        deleteStmt.setInt(1, imgId);
				        deleteStmt.executeUpdate();
				    }
				
				    selectStmt.close();
				    deleteStmt.close();
				}
                
                // 이미지 업로드를 처리하는 부분
                try {
                    Part filePart = request.getPart("images");
                    // 파일이 있고 크기가 0보다 큰 경우에만 업로드 처리
                    if (filePart != null && filePart.getSize() > 0) {
                        response.sendRedirect("/board/updatePost.jsp?boardId=" + boardId + "&postId=" + postId);
                    } else {
                        // 이미지가 없는 경우 바로 게시글 상세 페이지로 리다이렉트
                        response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);
                    }
                } catch (Exception e1) {
                    // Part 관련 예외 처리 - 파일이 없는 경우도 여기로 올 수 있음
                    response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);
                }
                return;
            } else {
                out.println("<p>제목과 내용은 필수입니다.</p>");
            }
        } catch (Exception e2) {
            out.println("<p>수정 실패: " + e2.getMessage() + "</p>");
        }
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
	    } catch (Exception e3) {
	        out.println("오류: " + e3.getMessage());
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
            width: 80%;
            max-width: 800px;
            margin: 20px auto;
            border: 1px solid #ddd;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            background-color: #fff;
        }
        .form-container h2 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
        }
        .form-field {
            margin: 15px 0;
        }
        .form-field label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"], textarea {
            width: 100%;
            padding: 10px;
            margin: 5px 0;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        textarea {
            height: 200px;
            resize: vertical;
        }
        input[type="file"] {
            width: 100%;
            padding: 10px;
            margin: 5px 0;
            box-sizing: border-box;
        }
        .button-group {
            text-align: center;
            margin-top: 20px;
        }
        button {
            width: 45%;
            padding: 10px;
            margin: 5px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        button[type="submit"] {
            background-color: #4CAF50;
            color: white;
        }
        button[type="submit"]:hover {
            background-color: #45a049;
        }
        button[type="button"] {
            background-color: #f44336;
            color: white;
        }
        button[type="button"]:hover {
            background-color: #d32f2f;
        }
        .image-container {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 10px;
        }
        .image-item {
            position: relative;
            width: 150px;
        }
        .thumbnail {
            width: 150px;
            height: 150px;
            object-fit: cover;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        .delete-checkbox {
            display: flex;
            align-items: center;
            margin-top: 5px;
        }
        .delete-checkbox input {
            margin-right: 5px;
            width: auto;
        }
        .error-message {
            color: #f44336;
            margin: 10px 0;
            padding: 10px;
            background-color: #ffebee;
            border-radius: 4px;
            display: none;
        }
    </style>
</head>
<body>

<div class="form-container">
    <h2>게시글 수정</h2>
    <div id="errorMessage" class="error-message"></div>
    <form method="post" enctype="multipart/form-data" action="/board/updatePost.jsp">
        <div class="form-field">
            <label>제목 (최대 100자):</label>
            <input type="text" name="title" id="title" maxlength="100" required value="<%= title %>">
        </div>
        <div class="form-field">
            <label>내용 (최대 2000자):</label>
            <textarea name="content" id="content" maxlength="2000" required><%= content %></textarea>
        </div>

        <!-- 기존 이미지 표시 -->
        <div class="form-field">
            <label>기존 이미지:</label>
            <div class="image-container">
            <%
                String imgSql = "SELECT IMAGE_ID, IMAGE_PATH FROM post_images WHERE POST_ID = ?";
                PreparedStatement imgStmt = conn.prepareStatement(imgSql);
                imgStmt.setInt(1, postId);
                ResultSet imgRs = imgStmt.executeQuery();
                boolean hasImages = false;
                
                while (imgRs.next()) {
                    hasImages = true;
                    int imageId = imgRs.getInt("IMAGE_ID");
                    String imagePath = imgRs.getString("IMAGE_PATH");
                    if (imagePath != null && !imagePath.trim().isEmpty()) {
            %>
                <div class="image-item">
                    <img src="<%= request.getContextPath() + "/" + imagePath %>" alt="이미지" class="thumbnail">
                    <div class="delete-checkbox">
                        <input type="checkbox" name="deleteImage" value="<%= imageId %>" id="img<%= imageId %>">
                        <label for="img<%= imageId %>">이 이미지 삭제</label>
                    </div>
                </div>
            <%
                    }
                }
                imgRs.close();
                imgStmt.close();
                
                if (!hasImages) {
                    out.println("<p>첨부된 이미지가 없습니다.</p>");
                }
            %>
            </div>
        </div>

        <!-- 새 이미지 업로드 -->
        <div class="form-field">
            <label>새 이미지 추가 (선택사항):</label>
            <input type="file" name="images" multiple accept="image/*">
            <small style="color: #666; display: block; margin-top: 5px;">* 이미지는 선택사항입니다. 이미지를 첨부하지 않아도 게시글을 수정할 수 있습니다.</small>
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