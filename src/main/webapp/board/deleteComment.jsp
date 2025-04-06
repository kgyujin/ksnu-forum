<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/db/dbConnection.jsp" %>

<%
    int commentId = Integer.parseInt(request.getParameter("commentId"));
    int postId = Integer.parseInt(request.getParameter("postId"));
    int boardId = Integer.parseInt(request.getParameter("boardId"));

    try {
        String sql = "UPDATE comments SET deleted = 'Y' WHERE COMMENT_ID = ?";
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setInt(1, commentId);
        int result = stmt.executeUpdate();

        if (result > 0) {
            response.sendRedirect("/board/boardView.jsp?postId=" + postId + "&boardId=" + boardId);
        } else {
            out.println("댓글 삭제 오류");
        }
    } catch (Exception e) {
        out.println("오류: " + e.getMessage());
    }
%>
