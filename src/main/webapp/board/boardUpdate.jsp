<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ page import="com.ksnu.service.PostService" %>

<%
    // 테스트용 임시 userId 지정
    // 실제 운영 시에는 주석 처리 또는 제거 필요
    if (session.getAttribute("userId") == null) {
        session.setAttribute("userId", "1"); // 임시 userId 설정 (1로 지정)
    }

    // 로그인 여부 확인
    Object userIdObj = session.getAttribute("userId");
    if (userIdObj == null) {
        response.sendRedirect("/login.jsp");
        return;
    }

    int userId = 0;
    try {
        userId = Integer.parseInt(userIdObj.toString());
    } catch (NumberFormatException e) {
        out.println("<p>유효하지 않은 사용자입니다. 다시 로그인 해주세요.</p>");
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
        PreparedStatement postStmt = null;
        ResultSet postRs = null;
        try {
            String postSql = "SELECT TITLE, CONTENT FROM POSTS WHERE POST_ID = ?";
            postStmt = conn.prepareStatement(postSql);
            postStmt.setInt(1, postId);
            postRs = postStmt.executeQuery();

            if (postRs.next()) {
                title = postRs.getString("TITLE");
                content = postRs.getString("CONTENT");
            } else {
                out.println("<p>게시글을 찾을 수 없습니다.</p>");
                return;
            }
        } catch (Exception e) {
            out.println("오류: " + e.getMessage());
        } finally {
            if (postRs != null) postRs.close();
            if (postStmt != null) postStmt.close();
        }
    }

    // 게시글 수정 처리
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        title = request.getParameter("title");
        content = request.getParameter("content");

        try {
            String updateSql = "UPDATE POSTS SET TITLE = ?, CONTENT = ?, UPDATED_AT = NOW() WHERE POST_ID = ? AND USER_ID = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, title);
            updateStmt.setString(2, content);
            updateStmt.setInt(3, postId);
            updateStmt.setInt(4, userId);

            int result = updateStmt.executeUpdate();

            if (result > 0) {
                response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);
            } else {
                out.println("<p>게시글 수정에 실패했습니다.</p>");
            }
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
    <form method="post">
        <div class="form-field">
            <label>제목 (최대 100자):</label>
            <input type="text" name="title" maxlength="100" required value="<%= title %>">
        </div>
        <div class="form-field">
            <label>내용 (최대 2000자):</label>
            <textarea name="content" maxlength="2000" required><%= content %></textarea>
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
