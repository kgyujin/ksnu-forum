<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.PagingUtil" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>내가 쓴 글 목록</title>
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
    int itemsPerPage = 10;
    int pageNum = PagingUtil.getPageNum(request);
    int offset = PagingUtil.calculateOffset(pageNum, itemsPerPage);

    int totalPosts = 0;
    int totalPages = 1;

    try {
        // 내가 쓴 글의 총 개수 구하기
        String countSql = "SELECT COUNT(*) AS total FROM POSTS WHERE USER_ID = ?";
        PreparedStatement countStmt = conn.prepareStatement(countSql);
        countStmt.setInt(1, userId);
        ResultSet countRs = countStmt.executeQuery();

        if (countRs.next()) {
            totalPosts = countRs.getInt("total");
            totalPages = PagingUtil.calculateTotalPages(totalPosts, itemsPerPage);
        }
%>

<h2 style="text-align:center;">내가 쓴 글 목록</h2>

<table>
    <tr>
        <th>번호</th>
        <th>제목</th>
        <th>작성일</th>
    </tr>
<%
        // 내가 쓴 글 목록 조회
        String postSql = "SELECT POST_ID, BOARD_ID, TITLE, CREATED_AT FROM POSTS WHERE USER_ID = ? ORDER BY CREATED_AT DESC LIMIT ? OFFSET ?";
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
    <%= PagingUtil.generatePagination(pageNum, totalPages, "/board/myPosts.jsp", "") %>
</div>
<%
    } catch (Exception e) {
        out.println("<p>게시글 조회 오류: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
