<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.PagingUtil" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>내가 스크랩한 글 목록</title>
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

    int totalScraps = 0;
    int totalPages = 1;

    try {
        // 내가 스크랩한 글의 총 개수 구하기
        String countSql = "SELECT COUNT(*) AS total FROM SCRAPS WHERE USER_ID = ?";
        PreparedStatement countStmt = conn.prepareStatement(countSql);
        countStmt.setInt(1, userId);
        ResultSet countRs = countStmt.executeQuery();

        if (countRs.next()) {
            totalScraps = countRs.getInt("total");
            totalPages = PagingUtil.calculateTotalPages(totalScraps, itemsPerPage);
        }
%>

<h2 style="text-align:center;">내가 스크랩한 글 목록</h2>

<table>
    <tr>
        <th>번호</th>
        <th>제목</th>
        <th>스크랩일</th>
    </tr>
<%
        // 내가 스크랩한 글 목록 조회
        String postSql = "SELECT P.BOARD_ID, P.POST_ID, P.TITLE, S.SCRAP_DATE " +
                         "FROM SCRAPS S JOIN POSTS P ON S.POST_ID = P.POST_ID " +
                         "WHERE S.USER_ID = ? " +
                         "ORDER BY S.SCRAP_DATE DESC LIMIT ? OFFSET ?";
        PreparedStatement postStmt = conn.prepareStatement(postSql);
        postStmt.setInt(1, userId);
        postStmt.setInt(2, itemsPerPage);
        postStmt.setInt(3, offset);
        ResultSet scrapRs = postStmt.executeQuery();

        int index = offset + 1;
        while (scrapRs.next()) {
            int boardId = scrapRs.getInt("BOARD_ID");
            int postId = scrapRs.getInt("POST_ID");
            String title = scrapRs.getString("TITLE");
            String scrapedAt = scrapRs.getString("SCRAP_DATE");
%>
    <tr>
        <td><%= index++ %></td>
        <td><a href="/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>"><%= title %></a></td>
        <td><%= scrapedAt %></td>
    </tr>
<%
        }
%>
</table>

<!-- 페이지 네비게이션 -->
<div class="pagination">
    <%= PagingUtil.generatePagination(pageNum, totalPages, "/board/myScraps.jsp", "") %>
</div>
<%
    } catch (Exception e) {
        out.println("<p>스크랩 글 조회 오류: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
