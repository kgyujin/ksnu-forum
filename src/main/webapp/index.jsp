<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>군산대학교 커뮤니티</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Pretendard', sans-serif;
        }

        body {
            color: #333;
            line-height: 1.6;
            background-color: #f8f9fa;
        }

        .main-container {
            display: flex;
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }

        /* 검색 영역 */
        .search-container {
            max-width: 1200px;
            margin: 20px auto 10px;
            text-align: center;
            padding: 0 20px;
        }

        .search-input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px 0 0 4px;
            width: 250px;
        }

        .search-button {
            background-color: #20409a;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 0 4px 4px 0;
            cursor: pointer;
        }

        /* 사이드바 영역 */
        .profile-sidebar {
            width: 250px;
            background-color: #f0f0f0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-right: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .profile-image {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            background-color: #ddd;
            margin-bottom: 15px;
        }

        .profile-name {
            font-size: 20px;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .profile-id {
            font-size: 16px;
            color: #666;
            margin-bottom: 20px;
        }

        .logout-button {
            background-color: #20409a;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 10px;
            width: 100%;
            text-align: center;
            font-size: 16px;
        }

        .delete-account-button {
            background-color: #dc3545;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            margin-bottom: 20px;
            width: 100%;
            text-align: center;
            font-size: 16px;
        }

        .menu-links {
            width: 100%;
            margin-top: 10px;
            border-top: 1px solid #ddd;
        }

        .menu-link {
            display: block;
            padding: 12px 0;
            text-align: center;
            color: #333;
            text-decoration: none;
            font-size: 16px;
            border-bottom: 1px solid #ddd;
        }

        .menu-link:hover {
            background-color: #e0e0e0;
        }

        /* 컨텐츠 영역 */
        .content {
            flex: 1;
        }

        /* 게시판 섹션 */
        .board-container {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
        }

        .board-section {
            flex: 1;
            min-width: 300px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .board-header {
            background-color: #f8f9fa;
            padding: 12px 15px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .board-title {
            font-size: 16px;
            font-weight: 600;
            color: #20409a;
        }

        .board-more {
            color: #666;
            font-size: 12px;
            text-decoration: none;
        }

        .board-item {
            display: flex;
            justify-content: space-between;
            padding: 12px 15px;
            border-bottom: 1px solid #f0f0f0;
        }

        .board-item:last-child {
            border-bottom: none;
        }

        .item-title {
            color: #333;
            text-decoration: none;
            flex: 1;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .item-title:hover {
            color: #20409a;
        }

        .item-date {
            color: #999;
            font-size: 12px;
            margin-left: 10px;
        }

        /* 핫 게시물 영역 */
        .hot-posts {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            margin-bottom: 20px;
        }

        .hot-posts-header {
            background-color: #f8f9fa;
            padding: 12px 15px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 16px;
            font-weight: 600;
            color: #dc3545;
        }

        .hot-item {
            padding: 12px 15px;
            border-bottom: 1px solid #f0f0f0;
        }

        .hot-item:last-child {
            border-bottom: none;
        }

        .hot-item a {
            color: #333;
            text-decoration: none;
            display: block;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .hot-item a:hover {
            color: #dc3545;
        }

        /* 반응형 스타일 */
        @media (max-width: 768px) {
            .main-container {
                flex-direction: column;
            }
            
            .profile-sidebar {
                width: 100%;
                margin-right: 0;
                margin-bottom: 20px;
            }
            
            .board-section {
                min-width: 100%;
            }
        }
    </style>
</head>
<body>
    <!-- 검색 영역 -->
    <div class="search-container">
        <form action="/board/search.jsp" method="get">
            <input type="text" name="query" placeholder="검색어를 입력하세요" class="search-input">
            <button type="submit" class="search-button">검색</button>
        </form>
    </div>

    <div class="main-container">
        <!-- 사이드바 영역 -->
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
        <div class="profile-sidebar">
            <div class="profile-image">
            	<img src="images/profile.png" alt="프로필 이미지" style="width: 100px; height: 100px; border-radius: 50%; object-fit: cover; margin-bottom: 10px;">
            </div>
            <div class="profile-name"><%= name %></div>
            <div class="profile-id"><%= stdNum %></div>
            
            <form action="LogoutServlet" method="get">
                <input type="submit" value="로그아웃" class="logout-button">
            </form>
            <form action="/DeleteAccountServlet" method="post">
                <button type="submit" class="delete-account-button">회원 탈퇴</button>
            </form>
            
            <div class="menu-links">
                <a href="board/myPosts.jsp" class="menu-link">내가 쓴 글</a>
                <a href="board/myComments.jsp" class="menu-link">댓글 단 글</a>
                <a href="board/myScraps.jsp" class="menu-link">내 스크랩</a>
            </div>
        </div>

        <!-- 컨텐츠 영역 -->
        <div class="content">
            <!-- HOT 게시물 영역 -->
            <div class="hot-posts">
                <div class="hot-posts-header">HOT 게시물</div>
                <%
                    PreparedStatement hotPostStmt = null;
                    ResultSet hotPostRs = null;
                    
                    try {
                        String hotPostSql = "SELECT POST_ID, TITLE, BOARD_ID, CREATED_AT, RECOMMEND_CNT " +
                                            "FROM POSTS WHERE CREATED_AT >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                                            "ORDER BY RECOMMEND_CNT DESC LIMIT 4";
                        hotPostStmt = conn.prepareStatement(hotPostSql);
                        hotPostRs = hotPostStmt.executeQuery();
                        
                        while (hotPostRs.next()) {
                            int postId = hotPostRs.getInt("POST_ID");
                            String title = hotPostRs.getString("TITLE");
                            int hotBoardId = hotPostRs.getInt("BOARD_ID");
                %>
                <div class="hot-item">
                    <a href="/board/boardView.jsp?boardId=<%= hotBoardId %>&postId=<%= postId %>"><%= title %></a>
                </div>
                <%
                        }
                    } catch (Exception e) {
                        out.println("HOT 게시물 데이터 조회 오류: " + e.getMessage());
                    } finally {
                        try {
                            if (hotPostRs != null) hotPostRs.close();
                            if (hotPostStmt != null) hotPostStmt.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </div>

            <!-- 게시판 영역 -->
            <div class="board-container">
                <%
                    PreparedStatement boardStmt = null;
                    PreparedStatement postStmt = null;
                    ResultSet boardRs = null;
                    ResultSet postRs = null;

                    try {
                        String boardSql = "SELECT BOARD_ID, BOARD_NAME FROM BOARDS ORDER BY BOARD_ID LIMIT 4";
                        boardStmt = conn.prepareStatement(boardSql);
                        boardRs = boardStmt.executeQuery();

                        while (boardRs.next()) {
                            int boardId = boardRs.getInt("BOARD_ID");
                            String boardName = boardRs.getString("BOARD_NAME");
                %>
                <div class="board-section">
                    <div class="board-header">
                        <div class="board-title"><%= boardName %></div>
                        <a href="/board/boardList.jsp?boardId=<%= boardId %>" class="board-more">더보기</a>
                    </div>
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
                    <div class="board-item">
                        <a href="/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>" class="item-title"><%= title %></a>
                        <span class="item-date"><%= createdAt.substring(5, 16) %></span>
                    </div>
                    <%
                        } // end of post while
                    %>
                </div>
                <%
                        } // end of board while
                    } catch (Exception e) {
                        out.println("게시판 데이터 조회 오류: " + e.getMessage());
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
        </div>
    </div>
</body>
</html>