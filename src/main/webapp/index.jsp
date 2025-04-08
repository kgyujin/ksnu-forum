<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

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

        .sidebar {
            width: 200px;
            background-color: #f9f9f9;
            border: 1px solid #e0e0e0;s
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

        .hot-posts {
            margin-left: 20px;
            padding: 15px;
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            width: 300px;
        }

        .hot-posts h3 {
            font-size: 18px;
            font-weight: bold;
            color: #c94c00;
            margin-bottom: 10px;
        }

        .hot-posts ul {
            list-style: none;
            padding: 0;
        }

        .hot-posts li {
            padding: 5px 0;
            border-bottom: 1px solid #e0e0e0;
        }

        .hot-posts a {
            text-decoration: none;
            color: #333;
        }

        .hot-posts a:hover {
            color: #20409a;
        }

        .boards-wrapper {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            flex: 1;
        }

        .board-section {
            width: calc(50% - 10px);
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            padding: 15px;
            box-sizing: border-box;
        }

        .board-title {
            font-size: 18px;
            font-weight: bold;
            color: #c94c00;
            margin-bottom: 10px;
        }

        .post-list {
            list-style: none;
            padding: 0;
        }

        .post-item {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
            border-bottom: 1px solid #eee;
        }

        .post-date {
            font-size: 12px;
            color: gray;
            white-space: nowrap;
        }

        a {
            text-decoration: none;
            color: black;
        }

        a:hover {
            color: #20409a;
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

        .logout-container {
            position: absolute;
            top: 10px;
            right: 10px;
        }

        .logout-button {
            text-decoration: none;
            color: white;
            background-color: #20409a;
            padding: 5px 10px;
            border-radius: 3px;
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

<div class="logout-container">
    <a href="/logout.jsp" class="logout-button">로그아웃</a>
</div>

<!-- Sidebar / 사이드바 시작 -->
<%
    String stdNum = "";
    String name = "";

    
    
    if (userId > 0) {
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT STD_NUM, NAME FROM users WHERE USER_ID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                stdNum = rs.getString("STD_NUM");
                name = rs.getString("NAME");
            }
        } catch (Exception e) {
            out.println("<script>alert('사용자 정보를 불러오는 중 오류 발생: " + e.getMessage() + "');</script>");
        }
    }
%>

<div style="width: 250px; background-color: #ddd; text-align: center; padding: 20px; border: 1px solid #ccc;">
    <img src="images/profile.png" alt="프로필 이미지" style="width: 100px; height: 100px; border-radius: 50%; object-fit: cover; margin-bottom: 10px;">
    <div style="color: gray; font-size: 20px;"><%= name %></div>
    <div style="color: gray; font-size: 16px; margin-bottom: 15px;"><%= stdNum %></div>
    
	<form action="LogoutServlet" method="get">
	    <input type="submit" value="로그아웃" style="padding: 8px 16px; font-size: 16px; margin-bottom: 20px;">
	</form>
	<form action="/DeleteAccountServlet" method="post" style="display: inline;">
        <button type="submit" class="logout-button" style="background-color: red;">회원 탈퇴</button>
    </form>
    <div style="background-color: white; padding: 0; border-top: 1px solid #fff;">
        <a href="myPosts.jsp" style="display: block; background-color: #ddd; padding: 15px 0; text-decoration: none; color: black; font-size: 20px;">내가 쓴 글</a>
        <a href="myComments.jsp" style="display: block; background-color: #ddd; padding: 15px 0; text-decoration: none; color: black; font-size: 20px;">댓글 단 글</a>
        <a href="myScraps.jsp" style="display: block; background-color: #ddd; padding: 15px 0; text-decoration: none; color: black; font-size: 20px;">내 스크랩</a>
    </div>
</div>

<!-- Sidebar / 사이드바 종료 -->

<div class="container">
    <div class="boards-wrapper">
        <%
            PreparedStatement boardStmt = null;
            PreparedStatement postStmt = null;
            PreparedStatement hotPostStmt = null;
            ResultSet boardRs = null;
            ResultSet postRs = null;
            ResultSet hotPostRs = null;

            try {
                String boardSql = "SELECT BOARD_ID, BOARD_NAME FROM BOARDS ORDER BY BOARD_ID LIMIT 4";
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
                    <span class="post-date"><%= createdAt.substring(5, 16) %></span>
                </li>
                <%
                    } // end of post while
                %>
            </ul>
        </div>
        <%
                } // end of board while

                // HOT 게시물은 게시판 루프 밖에서 한 번만 출력
                String hotPostSql = "SELECT POST_ID, TITLE, BOARD_ID, CREATED_AT, RECOMMEND_CNT " +
                                    "FROM POSTS WHERE CREATED_AT >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                                    "ORDER BY RECOMMEND_CNT DESC LIMIT 4";
                hotPostStmt = conn.prepareStatement(hotPostSql);
                hotPostRs = hotPostStmt.executeQuery();
        %>
        <div class="hot-posts">
            <h3>HOT 게시물</h3>
            <ul>
                <%
                    while (hotPostRs.next()) {
                        int postId = hotPostRs.getInt("POST_ID");
                        String title = hotPostRs.getString("TITLE");
                        int hotBoardId = hotPostRs.getInt("BOARD_ID");
                %>
                <li>
                    <a href="/board/boardView.jsp?boardId=<%= hotBoardId %>&postId=<%= postId %>"><%= title %></a>
                </li>
                <%
                    }
                %>
            </ul>
        </div>
        <%
            } catch (Exception e) {
                out.println("데이터 조회 오류: " + e.getMessage());
            } finally {
                try {
                    if (hotPostRs != null) hotPostRs.close();
                    if (postRs != null) postRs.close();
                    if (boardRs != null) boardRs.close();
                    if (hotPostStmt != null) hotPostStmt.close();
                    if (postStmt != null) postStmt.close();
                    if (boardStmt != null) boardStmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        %>
    </div>
</div>
</body>
</html>