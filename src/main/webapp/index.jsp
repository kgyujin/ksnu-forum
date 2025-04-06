<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>군산대학교 커뮤니티</title>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: 'Pretendard', sans-serif;
            background-color: #f5f5f5;
        }

        .container {
            display: flex;
            margin: 20px;
        }

        /* Sidebar */
        .sidebar {
            width: 200px;
            background-color: #f9f9f9;
            border: 1px solid #e0e0e0;
            margin-right: 20px;
            border-radius: 5px;
            padding: 10px;
        }

        .sidebar h3 {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 10px;
            color: #20409a;
        }

        .sidebar ul {
            list-style: none;
            padding: 0;
        }

        .sidebar li {
            padding: 10px;
            margin: 5px 0;
            background-color: #fff;
            border-radius: 5px;
            border: 1px solid #e0e0e0;
            cursor: pointer;
            display: flex;
            align-items: center;
        }

        .sidebar li:hover {
            background-color: #e0e0e0;
        }

        .sidebar li a {
            text-decoration: none;
            color: #333;
            margin-left: 5px;
        }

        .sidebar li i {
            font-size: 16px;
            color: #20409a;
        }

        /* Board Section */
        .board-section {
            display: inline-block;
            width: calc(100% - 240px);
            margin: 10px;
            vertical-align: top;
        }

        .board-title {
            font-size: 18px;
            font-weight: bold;
            color: #20409a;
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
            color: #c94c00;
        }

        .board-title a {
            color: #20409a;
            font-weight: bold;
        }

        .board-title a:hover {
            color: #c94c00;
        }

        .search-container {
            text-align: center;
            margin: 20px;
        }

        .search-input {
            padding: 5px;
            font-size: 16px;
            width: 300px;
            margin-right: 5px;
        }

        .search-button {
            padding: 5px 10px;
            font-size: 16px;
            background-color: #20409a;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
        }

        .search-button:hover {
            background-color: #c94c00;
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

<div class="container">
    <!-- Sidebar -->
    <div class="sidebar">
        <h3>내 활동</h3>
        <ul>
            <li>
                <i class="fas fa-list"></i>
                <a href="/board/myPosts.jsp">내가 쓴 글</a>
            </li>
            <li>
                <i class="fas fa-comment-dots"></i>
                <a href="/board/myComments.jsp">댓글 단 글</a>
            </li>
            <li>
                <i class="fas fa-star"></i>
                <a href="/board/myScrap.jsp">내 스크랩</a>
            </li>
        </ul>
    </div>

    <!-- Board Sections -->
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
                <a href="/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>"><%= title %></a>
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
</div>

</body>
</html>
