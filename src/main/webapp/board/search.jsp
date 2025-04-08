<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.PagingUtil" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>검색 결과</title>
    <meta charset="UTF-8">
    <style>
        .result-container {
            margin: 20px;
        }
        .result-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .result-item {
            margin: 15px 0;
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        .board-name {
            font-weight: bold;
            color: grey;
        }
        .post-title {
            font-size: 18px;
        }
        .post-info {
            font-size: 12px;
            color: gray;
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

<div class="result-container">
    <div class="result-title">검색 결과</div>
<%
    String query = request.getParameter("query");

    int itemsPerPage = 10;
    int pageNum = PagingUtil.getPageNum(request);
    int offset = PagingUtil.calculateOffset(pageNum, itemsPerPage);

    int totalPosts = 0;
    int totalPages = 1;

    if (query != null && !query.trim().isEmpty()) {
        PreparedStatement countStmt = null;
        ResultSet countRs = null;
        PreparedStatement searchStmt = null;
        ResultSet searchRs = null;

        try {
            // 게시글 수 조회
            String countSql = "SELECT COUNT(*) AS total FROM POSTS WHERE TITLE LIKE ?";
            countStmt = conn.prepareStatement(countSql);
            countStmt.setString(1, "%" + query + "%");
            countRs = countStmt.executeQuery();

            if (countRs.next()) {
                totalPosts = countRs.getInt("total");
                totalPages = PagingUtil.calculateTotalPages(totalPosts, itemsPerPage);
            }

            // 게시글 검색 쿼리 수정: BOARD_ID 추가
            String searchSql = "SELECT b.BOARD_NAME, p.TITLE, p.POST_ID, p.BOARD_ID, p.CREATED_AT "
                             + "FROM POSTS p JOIN BOARDS b ON p.BOARD_ID = b.BOARD_ID "
                             + "WHERE p.TITLE LIKE ? ORDER BY p.CREATED_AT DESC LIMIT ? OFFSET ?";
            searchStmt = conn.prepareStatement(searchSql);
            searchStmt.setString(1, "%" + query + "%");
            searchStmt.setInt(2, itemsPerPage);
            searchStmt.setInt(3, offset);
            searchRs = searchStmt.executeQuery();

            while (searchRs.next()) {
                String boardName = searchRs.getString("BOARD_NAME");
                String title = searchRs.getString("TITLE");
                int postId = searchRs.getInt("POST_ID");
                int boardId = searchRs.getInt("BOARD_ID");
                String createdAt = searchRs.getString("CREATED_AT");
%>
        <div class="result-item">
            <span class="board-name"><%= boardName %></span>
            <div class="post-title">
                <!-- 수정: boardId와 postId를 함께 넘김 -->
                <a href="/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>"><%= title %></a>
            </div>
            <div class="post-info">작성일: <%= createdAt %></div>
        </div>
<%
            }
        } catch (Exception e) {
            out.println("검색 오류: " + e.getMessage());
        } finally {
            if (searchRs != null) searchRs.close();
            if (searchStmt != null) searchStmt.close();
            if (countRs != null) countRs.close();
            if (countStmt != null) countStmt.close();
        }
    } else {
        out.println("<p>검색어를 입력해주세요.</p>");
    }
%>
</div>

<!-- 페이지 네비게이션 -->
<div class="pagination">
<%
    int groupSize = 10;
    int startPage = ((pageNum - 1) / groupSize) * groupSize + 1;
    int endPage = Math.min(startPage + groupSize - 1, totalPages);

    if (startPage > 1) {
%>
    <a href="?query=<%= query %>&page=1"><<</a>
    <a href="?query=<%= query %>&page=<%= startPage - 1 %>"><</a>
<%
    }

    for (int i = startPage; i <= endPage; i++) {
        if (i == pageNum) {
%>
        <span class="active"><%= i %></span>
<%
        } else {
%>
        <a href="?query=<%= query %>&page=<%= i %>"><%= i %></a>
<%
        }
    }

    if (endPage < totalPages) {
%>
    <a href="?query=<%= query %>&page=<%= endPage + 1 %>">></a>
    <a href="?query=<%= query %>&page=<%= totalPages %>">>></a>
<%
    }
%>
</div>

</body>
</html>
