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
        .board-container {
            width: 80%;
            margin: 20px auto;
        }
        .board-title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .board-table {
            width: 100%;
            border-collapse: collapse;
        }
        .board-table th, .board-table td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            text-align: center;
        }
        .board-table th {
            background-color: #f2f2f2;
        }
        .board-table td.title {
            text-align: left;
        }
        .board-table tr:hover {
            background-color: #f5f5f5;
        }
        .board-table td.title a {
            text-decoration: none;
            color: #333;
            transition: color 0.3s ease;
        }
        
        .board-table td.title a:hover {
            color: #007bff;
        }
        .write-btn {
            margin: 20px 0;
            text-align: right;
        }
        .write-btn a {
            padding: 8px 15px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
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

<div class="board-container">
    <div class="board-title">내가 스크랩한 글 목록</div>
    
    <table class="board-table">
        <thead>
            <tr>
                <th width="10%">게시판</th>
                <th width="55%">제목</th>
                <th width="20%">내용</th>
                <th width="15%">스크랩일</th>
            </tr>
        </thead>
        <tbody>
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

        // 내가 스크랩한 글 목록 조회 - 게시판 이름 추가
        String postSql = "SELECT P.BOARD_ID, P.POST_ID, P.TITLE, p.CONTENT, S.SCRAP_DATE, B.BOARD_NAME " +
                         "FROM SCRAPS S " +
                         "JOIN POSTS P ON S.POST_ID = P.POST_ID " +
                         "JOIN BOARDS B ON P.BOARD_ID = B.BOARD_ID " +
                         "WHERE S.USER_ID = ? " +
                         "ORDER BY S.SCRAP_DATE DESC LIMIT ? OFFSET ?";
        PreparedStatement postStmt = conn.prepareStatement(postSql);
        postStmt.setInt(1, userId);
        postStmt.setInt(2, itemsPerPage);
        postStmt.setInt(3, offset);
        ResultSet scrapRs = postStmt.executeQuery();

        int index = offset + 1;
        boolean hasResults = false;
        
        while (scrapRs.next()) {
            hasResults = true;
            int boardId = scrapRs.getInt("BOARD_ID");
            int postId = scrapRs.getInt("POST_ID");
            String title = scrapRs.getString("TITLE");
            String content = scrapRs.getString("CONTENT");
            String scrapedAt = scrapRs.getString("SCRAP_DATE");
            String boardName = scrapRs.getString("BOARD_NAME");
            
         	// 내용 요약 (10자 이상이면 자르고 ... 추가)
            String contentSummary = content;
            if (content != null && content.length() > 10) {
                contentSummary = content.substring(0, 10) + "...";
            }
%>
            <tr>
                <td><%= boardName %></td>
                <td class="title"><a href="/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>"><%= title %></a></td>
                <td><%= contentSummary %></td>
                <td><%= scrapedAt %></td>
            </tr>
<%
        }
        
        if (!hasResults) {
%>
            <tr>
                <td colspan="4" style="text-align: center;">스크랩한 글이 없습니다.</td>
            </tr>
<%
        }
%>
        </tbody>
    </table>

    <!-- 페이지 네비게이션 -->
    <div class="pagination">
<%
    int groupSize = 10;
    int startPage = ((pageNum - 1) / groupSize) * groupSize + 1;
    int endPage = Math.min(startPage + groupSize - 1, totalPages);

    if (startPage > 1) {
%>
        <a href="?page=1"><<</a>
        <a href="?page=<%= startPage - 1 %>"><</a>
<%
    }

    for (int i = startPage; i <= endPage; i++) {
        if (i == pageNum) {
%>
        <span class="active"><%= i %></span>
<%
        } else {
%>
        <a href="?page=<%= i %>"><%= i %></a>
<%
        }
    }

    if (endPage < totalPages) {
%>
        <a href="?page=<%= endPage + 1 %>">></a>
        <a href="?page=<%= totalPages %>">>></a>
<%
    }
%>
    </div>
</div>
<%
    } catch (Exception e) {
        out.println("<p>스크랩 글 조회 오류: " + e.getMessage() + "</p>");
    }
%>

</body>
</html>
