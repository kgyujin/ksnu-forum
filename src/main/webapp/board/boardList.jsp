<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>게시판 목록</title>
    <meta charset="UTF-8">
    <style>
        table {
            width: 80%;
            border-collapse: collapse;
            margin: 20px auto;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ddd;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        a {
            text-decoration: none;
            color: #333;
        }
        a:hover {
            color: blue;
        }
        /* 페이지 네비게이션 스타일 */
        .pagination {
            margin: 20px auto;
            text-align: center;
        }
        .pagination a, .pagination span {
            margin: 0 3px;
            padding: 5px 10px;
            text-decoration: none;
            color: black;
            border: 1px solid #ddd;
            border-radius: 5px;
            display: inline-block;
        }
        .pagination a:hover {
            background-color: #f2f2f2;
        }
        .pagination .active {
            font-weight: bold;
            background-color: #ddd;
        }
    </style>
</head>
<body>

<%
    int pageNum = 1;
    int itemsPerPage = 10;
    int groupSize = 10;
    int offset = 0;

    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try {
            pageNum = Integer.parseInt(pageParam);
            if (pageNum < 1) pageNum = 1;
        } catch (NumberFormatException e) {
            pageNum = 1;
        }
    }
    offset = (pageNum - 1) * itemsPerPage;

    String boardIdParam = request.getParameter("boardId");
    int boardId = 0;
    String boardName = "게시판";

    try {
        boardId = Integer.parseInt(boardIdParam);
    } catch (NumberFormatException e) {
        out.println("<p>잘못된 접근입니다.</p>");
        return;
    }

    PreparedStatement boardStmt = null;
    ResultSet boardRs = null;
    PreparedStatement postStmt = null;
    ResultSet postRs = null;
    PreparedStatement countStmt = null;
    ResultSet countRs = null;

    int totalPosts = 0;
    int totalPages = 1;

    try {
        String boardNameSql = "SELECT BOARD_NAME FROM BOARDS WHERE BOARD_ID = ?";
        boardStmt = conn.prepareStatement(boardNameSql);
        boardStmt.setInt(1, boardId);
        boardRs = boardStmt.executeQuery();

        if (boardRs.next()) {
            boardName = boardRs.getString("BOARD_NAME");
        }

        String countSql = "SELECT COUNT(*) AS total FROM POSTS WHERE BOARD_ID = ?";
        countStmt = conn.prepareStatement(countSql);
        countStmt.setInt(1, boardId);
        countRs = countStmt.executeQuery();

        if (countRs.next()) {
            totalPosts = countRs.getInt("total");
            totalPages = (int) Math.ceil((double) totalPosts / itemsPerPage);
        }
%>

<h2 style="text-align:center;"><%= boardName %> 목록</h2>
<table>
    <tr>
        <th>번호</th>
        <th>제목</th>
        <th>작성자</th>
        <th>작성일</th>
    </tr>
<%
        String postSql = "SELECT POST_ID, TITLE, USER_ID, CREATED_AT FROM POSTS WHERE BOARD_ID = ? ORDER BY CREATED_AT DESC LIMIT ? OFFSET ?";
        postStmt = conn.prepareStatement(postSql);
        postStmt.setInt(1, boardId);
        postStmt.setInt(2, itemsPerPage);
        postStmt.setInt(3, offset);
        postRs = postStmt.executeQuery();

        int index = offset + 1;
        while (postRs.next()) {
            int postId = postRs.getInt("POST_ID");
            String title = postRs.getString("TITLE");
            int userId = postRs.getInt("USER_ID");
            String createdAt = postRs.getString("CREATED_AT");
%>
    <tr>
        <td><%= index++ %></td>
        <td><a href="/board/boardView.jsp?postId=<%= postId %>"><%= title %></a></td>
        <td><%= userId %></td>
        <td><%= createdAt %></td>
    </tr>
<%
        }
    } catch (Exception e) {
        out.println("<p>게시글 조회 오류: " + e.getMessage() + "</p>");
    } finally {
        try {
            if (postRs != null) postRs.close();
            if (countRs != null) countRs.close();
            if (boardRs != null) boardRs.close();
            if (postStmt != null) postStmt.close();
            if (countStmt != null) countStmt.close();
            if (boardStmt != null) boardStmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
</table>

<!-- 페이지 네비게이션 -->
<div class="pagination">
<%
    int startPage = ((pageNum - 1) / groupSize) * groupSize + 1;
    int endPage = Math.min(startPage + groupSize - 1, totalPages);

    if (startPage > 1) {
%>
    <a href="?boardId=<%= boardId %>&page=1"><<</a>
    <a href="?boardId=<%= boardId %>&page=<%= startPage - 1 %>"><</a>
<%
    }

    for (int i = startPage; i <= endPage; i++) {
        if (i == pageNum) {
%>
        <span class="active"><%= i %></span>
<%
        } else {
%>
        <a href="?boardId=<%= boardId %>&page=<%= i %>"><%= i %></a>
<%
        }
    }

    if (endPage < totalPages) {
%>
    <a href="?boardId=<%= boardId %>&page=<%= endPage + 1 %>">></a>
    <a href="?boardId=<%= boardId %>&page=<%= totalPages %>">>></a>
<%
    }
%>
</div>

</body>
</html>
