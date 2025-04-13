<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ page import="com.ksnu.service.PostService" %>
<%@ page import="jakarta.servlet.http.Part" %>

<%
    int boardId = 0;

    try {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            boardId = Integer.parseInt(request.getParameter("boardId"));
	        
	        if (title != null && content != null)
	        {
	            // 게시글 추가
	            boolean isSuccess = PostService.addPost(conn, boardId, userId, title, content);
	            
	            if (isSuccess) {
                    response.sendRedirect("/board/boardList.jsp?boardId=" + boardId);
                }
                return;
            }
	        else
	        {
                out.println("<p>게시글 등록에 실패했습니다.</p>");
            }
        }
    } catch (Exception e) {
        out.println("<p>오류 발생: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>게시글 작성</title>
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
    <h2>게시글 작성</h2>
    <div id="errorMessage" class="error-message"></div>
    <form method="post" enctype="multipart/form-data" action="/board/uploadFiles.jsp">
        <div class="form-field">
            <label>제목 (최대 100자):</label>
            <input type="text" name="title" id="title" maxlength="100" required>
        </div>
        <div class="form-field">
            <label>내용 (최대 2000자):</label>
            <textarea name="content" id="content" maxlength="2000" required></textarea>
        </div>
        <div class="form-field">
            <label>이미지 업로드 (선택사항):</label>
            <input type="file" name="images" multiple accept="image/*">
            <small style="color: #666; display: block; margin-top: 5px;">* 이미지는 선택사항입니다. 이미지를 첨부하지 않아도 게시글을 등록할 수 있습니다.</small>
        </div>
        <!-- boardId를 Hidden 필드로 추가 -->
        <input type="hidden" name="boardId" value="<%= request.getParameter("boardId") %>">
        <div class="button-group">
            <button type="submit">작성</button>
			<button type="button" onclick="location.href='/board/boardList.jsp?boardId=<%= request.getParameter("boardId") %>'">취소</button>
        </div>
    </form>
</div>
</body>
</html>