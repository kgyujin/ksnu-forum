<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.PagingUtil" %>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>게시판</title>
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
            padding-bottom: 10px;
            border-bottom: 1px solid #ddd;
        }
        .post-item {
            padding: 15px 0;
            border-bottom: 1px solid #eee;
            display: flex;
            align-items: flex-start;
        }
        .post-content {
            flex: 1;
        }
        .post-title {
            font-size: 16px;
            margin-bottom: 5px;
        }
        .post-title a {
            text-decoration: none;
            color: #333;
            transition: color 0.3s ease;
        }
        .post-title a:hover {
            color: #007bff;
        }
        .post-excerpt {
            font-size: 13px;
            color: #666;
            margin-bottom: 5px;
            line-height: 1.4;
            max-height: 36px;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
        }
        .post-info {
            font-size: 12px;
            color: #888;
            display: flex;
            align-items: center;
        }
        .post-info span {
            margin-right: 15px;
        }
        .post-thumbnail {
            width: 60px;
            height: 60px;
            margin-left: 15px;
            overflow: hidden;
            border-radius: 4px;
        }
        .post-thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .comment-count, .recommend-count {
            display: inline-flex;
            align-items: center;
        }
        .comment-count:before {
            content: "💬";
            margin-right: 3px;
        }
        .recommend-count:before {
            content: "👍";
            margin-right: 3px;
        }
        .top-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .sort-options {
            display: flex;
            align-items: center;
        }
        .sort-options select {
            padding: 6px 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-left: 10px;
        }
        .write-btn {
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

<%
    int boardId = 0;
    String boardName = "";
    
    try {
        boardId = Integer.parseInt(request.getParameter("boardId"));
    } catch (Exception e) {
        response.sendRedirect("/index.jsp");
        return;
    }
    
    // 정렬 방식 파라미터 가져오기
    String sortBy = request.getParameter("sortBy");
    if (sortBy == null || sortBy.isEmpty()) {
        sortBy = "time"; // 기본 정렬은 시간순
    }
    
    // 게시판 정보 조회
    PreparedStatement boardStmt = null;
    ResultSet boardRs = null;
    
    try {
        String boardSql = "SELECT BOARD_NAME FROM BOARDS WHERE BOARD_ID = ?";
        boardStmt = conn.prepareStatement(boardSql);
        boardStmt.setInt(1, boardId);
        boardRs = boardStmt.executeQuery();
        
        if (boardRs.next()) {
            boardName = boardRs.getString("BOARD_NAME");
        } else {
            response.sendRedirect("/index.jsp");
            return;
        }
    } catch (Exception e) {
        out.println("게시판 정보 조회 오류: " + e.getMessage());
        return;
    } finally {
        if (boardRs != null) boardRs.close();
        if (boardStmt != null) boardStmt.close();
    }
%>

<div class="board-container">
    <div class="board-title"><%= boardName %></div>
    
    <div class="top-actions">
        <div class="sort-options">
            <label for="sortSelect">정렬:</label>
            <select id="sortSelect" onchange="changeSortOrder()">
                <option value="time" <%= sortBy.equals("time") ? "selected" : "" %>>최신순</option>
                <option value="recommend" <%= sortBy.equals("recommend") ? "selected" : "" %>>추천순</option>
                <option value="comment" <%= sortBy.equals("comment") ? "selected" : "" %>>댓글순</option>
            </select>
        </div>
        <div class="write-btn">
            <a href="boardAdd.jsp?boardId=<%= boardId %>">글쓰기</a>
        </div>
    </div>
    
    <div class="post-list">
<%
    int itemsPerPage = 10;
    int pageNum = PagingUtil.getPageNum(request);
    int offset = PagingUtil.calculateOffset(pageNum, itemsPerPage);
    
    int totalPosts = 0;
    int totalPages = 1;
    
    PreparedStatement countStmt = null;
    ResultSet countRs = null;
    PreparedStatement postStmt = null;
    ResultSet postRs = null;
    
    try {
        // 게시글 수 조회
        String countSql = "SELECT COUNT(*) AS total FROM POSTS WHERE BOARD_ID = ?";
        countStmt = conn.prepareStatement(countSql);
        countStmt.setInt(1, boardId);
        countRs = countStmt.executeQuery();
        
        if (countRs.next()) {
            totalPosts = countRs.getInt("total");
            totalPages = PagingUtil.calculateTotalPages(totalPosts, itemsPerPage);
        }
        
        // 정렬 방식에 따른 SQL 쿼리 작성
        String orderByClause = "";
        String joinClause = "";
        
        if (sortBy.equals("recommend")) {
            orderByClause = "ORDER BY p.RECOMMEND_CNT DESC, p.CREATED_AT DESC";
        } else if (sortBy.equals("comment")) {
            joinClause = "LEFT JOIN (SELECT POST_ID, COUNT(*) as COMMENT_COUNT FROM COMMENTS GROUP BY POST_ID) c ON p.POST_ID = c.POST_ID";
            orderByClause = "ORDER BY IFNULL(c.COMMENT_COUNT, 0) DESC, p.CREATED_AT DESC";
        } else {
            // 기본 시간순 정렬
            orderByClause = "ORDER BY p.CREATED_AT DESC";
        }
        
        // 게시글 목록 조회 - post_images 테이블에서 이미지 가져오기 및 CONTENT 추가
        String postSql = "SELECT p.POST_ID, p.TITLE, p.CONTENT, p.CREATED_AT, p.RECOMMEND_CNT, u.NAME, " +
                         "(SELECT COUNT(*) FROM COMMENTS WHERE POST_ID = p.POST_ID) AS COMMENT_COUNT, " +
                         "MIN(pi.IMAGE_PATH) AS THUMBNAIL_PATH " +
                         "FROM POSTS p " +
                         "JOIN USERS u ON p.USER_ID = u.USER_ID " +
                         "LEFT JOIN post_images pi ON p.POST_ID = pi.POST_ID " +
                         joinClause +
                         " WHERE p.BOARD_ID = ? " +
                         "GROUP BY p.POST_ID, p.TITLE, p.CONTENT, p.CREATED_AT, p.RECOMMEND_CNT, u.NAME " +
                         orderByClause +
                         " LIMIT ? OFFSET ?";
        postStmt = conn.prepareStatement(postSql);
        postStmt.setInt(1, boardId);
        postStmt.setInt(2, itemsPerPage);
        postStmt.setInt(3, offset);
        postRs = postStmt.executeQuery();
        
        boolean hasResults = false;
        
        while (postRs.next()) {
            hasResults = true;
            int postId = postRs.getInt("POST_ID");
            String title = postRs.getString("TITLE");
            String content = postRs.getString("CONTENT");
            String author = postRs.getString("NAME");
            String createdAt = postRs.getString("CREATED_AT");
            String thumbnailPath = postRs.getString("THUMBNAIL_PATH");
            int recommendCnt = postRs.getInt("RECOMMEND_CNT");
            int commentCount = postRs.getInt("COMMENT_COUNT");
            
            // 내용 요약 (50자 이상이면 자르고 ... 추가)
            String contentSummary = content;
            if (content != null && content.length() > 50) {
                contentSummary = content.substring(0, 50) + "...";
            }
%>
        <div class="post-item">
            <div class="post-content">
                <div class="post-title">
                    <a href="boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>"><%= title %></a>
                </div>
                <div class="post-excerpt"><%= contentSummary %></div>
                <div class="post-info">
                    <span class="recommend-count"><%= recommendCnt %></span>
                    <span class="comment-count"><%= commentCount %></span>
                    <span><%= createdAt %></span>
                    <span>익명</span>
                </div>
            </div>
            <% if (thumbnailPath != null && !thumbnailPath.isEmpty()) { %>
            <div class="post-thumbnail">
                <img src="<%= request.getContextPath() + "/" + thumbnailPath %>" alt="썸네일">
            </div>
            <% } %>
        </div>
<%
        }
        
        if (!hasResults) {
%>
        <div style="text-align: center; padding: 30px 0;">
            게시글이 없습니다.
        </div>
<%
        }
    } catch (Exception e) {
        out.println("게시글 목록 조회 오류: " + e.getMessage());
    } finally {
        if (postRs != null) postRs.close();
        if (postStmt != null) postStmt.close();
        if (countRs != null) countRs.close();
        if (countStmt != null) countStmt.close();
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
        <a href="?boardId=<%= boardId %>&sortBy=<%= sortBy %>&page=1"><<</a>
        <a href="?boardId=<%= boardId %>&sortBy=<%= sortBy %>&page=<%= startPage - 1 %>"><</a>
<%
    }
    
    for (int i = startPage; i <= endPage; i++) {
        if (i == pageNum) {
%>
        <span class="active"><%= i %></span>
<%
        } else {
%>
        <a href="?boardId=<%= boardId %>&sortBy=<%= sortBy %>&page=<%= i %>"><%= i %></a>
<%
        }
    }
    
    if (endPage < totalPages) {
%>
        <a href="?boardId=<%= boardId %>&sortBy=<%= sortBy %>&page=<%= endPage + 1 %>">></a>
        <a href="?boardId=<%= boardId %>&sortBy=<%= sortBy %>&page=<%= totalPages %>">>></a>
<%
    }
%>
    </div>
</div>

<script>
    function changeSortOrder() {
        const sortSelect = document.getElementById('sortSelect');
        const selectedValue = sortSelect.value;
        window.location.href = '?boardId=<%= boardId %>&sortBy=' + selectedValue;
    }
</script>

</body>
</html>
