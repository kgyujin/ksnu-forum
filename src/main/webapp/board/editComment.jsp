<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/db/dbConnection.jsp" %>

<%
    int commentId = 0;
    int postId = 0;
    int boardId = 0;
    String content = "";

    try {
        if (request.getParameter("commentId") != null) {
            commentId = Integer.parseInt(request.getParameter("commentId"));
        }
        if (request.getParameter("postId") != null) {
            postId = Integer.parseInt(request.getParameter("postId"));
        }
        if (request.getParameter("boardId") != null) {
            boardId = Integer.parseInt(request.getParameter("boardId"));
        }

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            if (request.getParameter("content") != null) {
                content = java.net.URLDecoder.decode(request.getParameter("content"), "UTF-8");
            } else {
                PreparedStatement stmt = null;
                ResultSet rs = null;
                try {
                    String sql = "SELECT CONTENT FROM comments WHERE COMMENT_ID = ?";
                    stmt = conn.prepareStatement(sql);
                    stmt.setInt(1, commentId);
                    rs = stmt.executeQuery();

                    if (rs.next()) {
                        content = rs.getString("CONTENT");
                    } else {
                        out.println("<p>댓글을 찾을 수 없습니다.</p>");
                        return;
                    }
                } catch (Exception e) {
                    out.println("오류: " + e.getMessage());
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
                    if (stmt != null) try { stmt.close(); } catch (Exception e) { e.printStackTrace(); }
                }
            }
        }

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            content = request.getParameter("content");

            if (content == null || content.trim().isEmpty()) {
                out.println("<p>댓글 내용이 비어있습니다.</p>");
                return;
            }

            try {
                String updateSql = "UPDATE comments SET CONTENT = ?, UPDATED_AT = NOW() WHERE COMMENT_ID = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, content);
                updateStmt.setInt(2, commentId);

                int result = updateStmt.executeUpdate();
                updateStmt.close();

                if (result > 0) {
                    response.sendRedirect("/board/boardView.jsp?postId=" + postId + "&boardId=" + boardId);
                } else {
                    out.println("<p>댓글 수정에 실패했습니다.</p>");
                }
            } catch (Exception e) {
                out.println("댓글 수정 오류: " + e.getMessage());
            }
        }
    } catch (NumberFormatException e) {
        out.println("<p>잘못된 요청입니다. (잘못된 번호 형식)</p>");
    } catch (Exception e) {
        out.println("댓글 수정 처리 오류: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>댓글 수정</title>
    <meta charset="UTF-8">
    <style>
    	body {
    		font-family: 'Pretendard', sans-serif;
    	}
    	
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
        textarea {
            width: 100%;
            padding: 10px;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            height: 150px;
            resize: vertical;
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
    </style>
</head>
<body>
    <div class="form-container">
        <h2>댓글 수정</h2>
        <form method="post">
            <div class="form-field">
                <label>내용 (최대 2000자):</label>
                <textarea name="content" maxlength="2000" required><%= content %></textarea>
            </div>
            <div class="button-group">
                <button type="submit">수정 완료</button>
                <button type="button" onclick="location.href='/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>'">취소</button>
            </div>
            <input type="hidden" name="boardId" value="<%= boardId %>">
            <input type="hidden" name="postId" value="<%= postId %>">
            <input type="hidden" name="commentId" value="<%= commentId %>">
        </form>
    </div>
</body>
</html>
