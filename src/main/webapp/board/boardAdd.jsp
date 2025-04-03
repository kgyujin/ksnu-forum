<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
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

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        int boardId = Integer.parseInt(request.getParameter("boardId"));

        boolean isSuccess = PostService.addPost(conn, boardId, userId, title, content);
        if (isSuccess) {
            response.sendRedirect("/board/boardList.jsp?boardId=" + boardId);
            return;
        } else {
            out.println("<p>게시글 등록에 실패했습니다.</p>");
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>게시글 작성</title>
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
    <h2>게시글 작성</h2>
    <form method="post">
        <div class="form-field">
            <label>제목 (최대 100자):</label>
            <input type="text" name="title" maxlength="100" required>
        </div>
        <div class="form-field">
            <label>내용 (최대 2000자):</label>
            <textarea name="content" maxlength="2000" required></textarea>
        </div>
        <div class="button-group">
            <button type="submit">작성</button>
            <button type="button" onclick="location.href='/board/boardList.jsp?boardId=<%= request.getParameter("boardId") %>'">취소</button>
        </div>
        <input type="hidden" name="boardId" value="<%= request.getParameter("boardId") %>">
    </form>
</div>

</body>
</html>
