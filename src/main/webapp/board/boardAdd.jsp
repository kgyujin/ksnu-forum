<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ page import="com.ksnu.service.PostService" %>

<%
	int boardId = 0;
	
    try {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            boardId = Integer.parseInt(request.getParameter("boardId"));

            // 게시글 추가
            boolean isSuccess = PostService.addPost(conn, boardId, userId, title, content);
            if (isSuccess) {
                response.sendRedirect("/board/boardList.jsp?boardId=" + boardId);
                return;
            } else {
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
</head>
<body>
<div class="form-container">
    <h2>게시글 작성</h2>
    <form method="post" enctype="multipart/form-data" action="/board/uploadFiles.jsp">
        <div class="form-field">
            <label>제목 (최대 100자):</label>
            <input type="text" name="title" maxlength="100" required>
        </div>
        <div class="form-field">
            <label>내용 (최대 2000자):</label>
            <textarea name="content" maxlength="2000" required></textarea>
        </div>
        <div class="form-field">
            <label>이미지 업로드</label>
            <input type="file" name="images" multiple accept="image/*">
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