<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.PagingUtil" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>게시판 목록</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="container">
        <%
            int itemsPerPage = 10;
            int pageNum = PagingUtil.getPageNum(request);
            int offset = PagingUtil.calculateOffset(pageNum, itemsPerPage);

            String boardIdParam = request.getParameter("boardId");
            int boardId = 0;
            String boardName = "게시판";

            try {
                boardId = Integer.parseInt(boardIdParam);
            } catch (NumberFormatException e) {
                out.println("<p>잘못된 접근입니다.</p>");
                return;
            }

            int totalPosts = 0;
            int totalPages = 1;

            try {
                String countSql = "SELECT COUNT(*) AS total FROM POSTS WHERE BOARD_ID = ?";
                PreparedStatement countStmt = conn.prepareStatement(countSql);
                countStmt.setInt(1, boardId);
                ResultSet countRs = countStmt.executeQuery();

                if (countRs.next()) {
                    totalPosts = countRs.getInt("total");
                    totalPages = PagingUtil.calculateTotalPages(totalPosts, itemsPerPage);
                }
        %>

        <h2><%= boardName %> 목록</h2>
        <!-- 글 작성 버튼 추가 -->
        <div style="text-align: center; margin: 20px;">
            <a href="${pageContext.request.contextPath}/board/boardAdd.jsp?boardId=<%= boardId %>" class="add-button">글 작성</a>
        </div>

        <%
                String postSql = "SELECT POST_ID, TITLE, CONTENT, USER_ID, CREATED_AT, " +
                                "(SELECT COUNT(*) FROM RECOMMENDS WHERE POST_ID = P.POST_ID) AS RECOMMEND_COUNT, " +
                                "(SELECT COUNT(*) FROM COMMENTS WHERE POST_ID = P.POST_ID) AS COMMENT_COUNT " +
                                "FROM POSTS P WHERE BOARD_ID = ? ORDER BY CREATED_AT DESC LIMIT ? OFFSET ?";
                PreparedStatement postStmt = conn.prepareStatement(postSql);
                postStmt.setInt(1, boardId);
                postStmt.setInt(2, itemsPerPage);
                postStmt.setInt(3, offset);
                ResultSet postRs = postStmt.executeQuery();

                while (postRs.next()) {
                    int postId = postRs.getInt("POST_ID");
                    String title = postRs.getString("TITLE");
                    String content = postRs.getString("CONTENT");
                    String postUserId = postRs.getString("USER_ID");
                    String createdAt = postRs.getString("CREATED_AT");
                    int recommendCount = postRs.getInt("RECOMMEND_COUNT");
                    int commentCount = postRs.getInt("COMMENT_COUNT");

                    String shortContent = content.length() > 50 ? content.substring(0, 50) + "..." : content;

                    String thumbSql = "SELECT IMAGE_PATH FROM post_images WHERE POST_ID = ? LIMIT 1";
                    PreparedStatement thumbStmt = conn.prepareStatement(thumbSql);
                    thumbStmt.setInt(1, postId);
                    ResultSet thumbRs = thumbStmt.executeQuery();

                    String thumbnail = "";
                    if (thumbRs.next()) {
                        thumbnail = request.getContextPath() + "/" + thumbRs.getString("IMAGE_PATH");
                    }
                    thumbRs.close();
                    thumbStmt.close();
        %>
            <div class="post-card" onclick="location.href='${pageContext.request.contextPath}/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>'">
                <div class="post-content">
                    <p class="post-title"><%= title %></p>
                    <p class="post-info"><%= shortContent %></p>
                    <div class="post-icons">
                        <span class="icon">💖 <%= recommendCount %></span>
                        <span class="icon">💬 <%= commentCount %></span>
                        <span class="timestamp"><%= createdAt.substring(0, 16) %></span>
                    </div>
                </div>
                <% if (!thumbnail.isEmpty()) { %>
                    <img src="<%= thumbnail %>" alt="썸네일" class="thumbnail">
                <% } %>
            </div>
        <%
                }
        %>

        <div class="pagination">
            <%= PagingUtil.generatePagination(pageNum, totalPages, "/board/boardList.jsp", "boardId=" + boardId) %>
        </div>
        <%
            } catch (Exception e) {
                out.println("<p>게시글 조회 오류: " + e.getMessage() + "</p>");
            }
        %>
    </div>
</body>
</html>