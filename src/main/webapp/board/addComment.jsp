<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<%
    int postId = 0;
    int boardId = 0;
    int parentId = 0;
    String content = "";

    try {
        if (request.getParameter("postId") != null) {
            postId = Integer.parseInt(request.getParameter("postId"));
        }

        if (request.getParameter("boardId") != null) {
            boardId = Integer.parseInt(request.getParameter("boardId"));
        } else {
            out.println("<p>게시판 ID가 없습니다. 잘못된 접근입니다.</p>");
            return;
        }

        if (request.getParameter("parentId") != null && !request.getParameter("parentId").isEmpty()) {
            parentId = Integer.parseInt(request.getParameter("parentId"));
        }

        if (request.getParameter("content") != null) {
            content = request.getParameter("content").trim();
        }

        if (content.isEmpty()) {
            out.println("<p>댓글 내용을 입력하세요.</p>");
            return;
        }

        String sql = "INSERT INTO comments (POST_ID, USER_ID, BOARD_ID, CONTENT, CREATED_AT, PARENT_ID) VALUES (?, ?, ?, ?, NOW(), ?)";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, postId);
        stmt.setInt(2, userId);
        stmt.setInt(3, boardId);
        stmt.setString(4, content);
        stmt.setInt(5, parentId);
        stmt.executeUpdate();

        response.sendRedirect("/board/boardView.jsp?postId=" + postId + "&boardId=" + boardId);
    } catch (NumberFormatException e) {
        out.println("<p>잘못된 데이터 형식입니다. 다시 시도하세요.</p>");
    } catch (Exception e) {
        out.println("<p>댓글 등록 중 오류 발생: " + e.getMessage() + "</p>");
    }
%>