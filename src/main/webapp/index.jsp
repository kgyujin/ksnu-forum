<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>군산대학교 커뮤니티</title>
    <meta charset="UTF-8">
    <style>
        .board-section {
            display: inline-block;
            width: 45%;
            margin: 10px;
            vertical-align: top;
        }
        .board-title {
            font-size: 18px;
            font-weight: bold;
            color: red;
            margin-bottom: 5px;
        }
        .post-list {
            list-style: none;
            padding: 0;
        }
        .post-item {
            margin: 5px 0;
        }
        .post-date {
            font-size: 12px;
            color: gray;
        }
        a {
            text-decoration: none;
            color: black;
        }
        a:hover {
            color: blue;
        }
        .board-title a {
            color: red;
            font-weight: bold;
        }
        .board-title a:hover {
            color: darkred;
        }
        .search-container {
            text-align: center;
            margin: 20px;
        }
        .search-input {
            padding: 5px;
            font-size: 16px;
            width: 300px;
        }
        .search-button {
            padding: 5px 10px;
            font-size: 16px;
        }
    </style>
</head>
<body>

<div class="search-container">
    <form action="/board/search.jsp" method="get">
        <input type="text" name="query" placeholder="검색어를 입력하세요" class="search-input">
        <button type="submit" class="search-button">검색</button>
    </form>
</div>

<%
    PreparedStatement boardStmt = null;
    PreparedStatement postStmt = null;
    ResultSet boardRs = null;
    ResultSet postRs = null;

    try {
        String boardSql = "SELECT BOARD_ID, BOARD_NAME FROM BOARDS";
        boardStmt = conn.prepareStatement(boardSql);
        boardRs = boardStmt.executeQuery();

        while (boardRs.next()) {
            int boardId = boardRs.getInt("BOARD_ID");
            String boardName = boardRs.getString("BOARD_NAME");
%>

<div class="board-section">
    <div class="board-title">
        <a href="/board/boardList.jsp?boardId=<%= boardId %>"><%= boardName %></a>
    </div>
    <ul class="post-list">
<%
            String postSql = "SELECT POST_ID, TITLE, CREATED_AT FROM POSTS WHERE BOARD_ID = ? ORDER BY CREATED_AT DESC LIMIT 4";
            postStmt = conn.prepareStatement(postSql);
            postStmt.setInt(1, boardId);
            postRs = postStmt.executeQuery();

            while (postRs.next()) {
                int postId = postRs.getInt("POST_ID");
                String title = postRs.getString("TITLE");
                String createdAt = postRs.getString("CREATED_AT");
%>
        <li class="post-item">
            <a href="/board/boardView.jsp?postId=<%= postId %>"><%= title %></a>
            <span class="post-date">(<%= createdAt %>)</span>
        </li>
<%
            }
%>
    </ul>
</div>

<%
        }
    } catch (Exception e) {
        out.println("데이터 조회 오류: " + e.getMessage());
    } finally {
        try {
            if (postRs != null) postRs.close();
            if (boardRs != null) boardRs.close();
            if (postStmt != null) postStmt.close();
            if (boardStmt != null) boardStmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

</body>
</html>
