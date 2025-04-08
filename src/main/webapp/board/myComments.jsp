<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.PagingUtil" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>댓글 단 글 목록</title>
    <meta charset="UTF-8">
</head>
<body>

<%
    int itemsPerPage = 10;
    int pageNum = PagingUtil.getPageNum(request);
    int offset = PagingUtil.calculateOffset(pageNum, itemsPerPage);

    int totalPosts = 0;
    int totalPages = 1;

    try {
        // 내가 댓글 단 게시글 수 구하기
        String countSql = "SELECT COUNT(DISTINCT p.POST_ID) AS total " +
                          "FROM POSTS p " +
                          "JOIN COMMENTS c ON p.POST_ID = c.POST_ID " +
                          "WHERE c.USER_ID = ?";
        PreparedStatement countStmt = conn.prepareStatement(countSql);
        countStmt.setInt(1, userId);
        ResultSet countRs = countStmt.executeQuery();

        if (countRs.next()) {
            totalPosts = countRs.getInt("total");
            totalPages = PagingUtil.calculateTotalPages(totalPosts, itemsPerPage);
        }
%>

<h2 style="text-align:center;">댓글 단 글 목록</h2>

<table>
    <tr>
        <th>번호</th>
        <th>제목</th>
        <th>작성일</th>
    </tr>
<%
        // 내가 댓글 단 게시글 목록 조회
        String postSql = "SELECT DISTINCT p.POST_ID, p.BOARD_ID, p.TITLE, p.CREATED_AT " +
                         "FROM POSTS p " +
                         "JOIN COMMENTS c ON p.POST_ID = c.POST_ID " +
                         "WHERE c.USER_ID = ? " +
                         "ORDER BY p.CREATED_AT DESC " +
                         "LIMIT ? OFFSET ?";
        PreparedStatement postStmt = conn.prepareStatement(postSql);
        postStmt.setInt(1, userId);
        postStmt.setInt(2, itemsPerPage);
        postStmt.setInt(3, offset);
        ResultSet postRs = postStmt.executeQuery();

        int index = offset + 1;
        while (postRs.next()) {
            int postId = postRs.getInt("POST_ID");
            int boardId = postRs.getInt("BOARD_ID");
            String title = postRs.getString("TITLE");
            String createdAt = postRs.getString("CREATED_AT");
%>
    <tr>
        <td><%= index++ %></td>
        <td><a href="/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>"><%= title %></a></td>
        <td><%= createdAt %></td>
    </tr>
<%
        }
%>
</table>

<!-- 페이지 네비게이션 -->
<div class="pagination">
    <%= PagingUtil.generatePagination(pageNum, totalPages, "/board/myComments.jsp", "") %>
</div>
<%
    } catch (Exception e) {
        out.println("<p>게시글 조회 오류: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
