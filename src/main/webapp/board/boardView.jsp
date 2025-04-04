<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>게시글 보기</title>
    <meta charset="UTF-8">
    <style>
        .post-title {
            font-size: 24px;
            font-weight: bold;
        }
        .post-info {
            color: gray;
            margin-bottom: 10px;
        }
        .reaction {
            display: inline-block;
            margin: 5px;
            padding: 5px 10px;
            border-radius: 5px;
            cursor: pointer;
        }
        .reaction:hover {
            background-color: #f0f0f0;
        }
        .active {
            background-color: #ff5555;
            color: white;
        }
        .comment-section {
            margin-top: 20px;
        }
        .comment-input {
            width: 80%;
            padding: 8px;
            margin: 5px;
        }
        .comment-item {
            margin: 5px 0;
        }
        .back-button {
            margin-top: 20px;
            background-color: red;
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            text-decoration: none;
        }
    </style>
</head>
<body>

<%
    int postId = 0;
    int boardId = 0;

    // 테스트용 임시 userId 지정
    // 실제 운영 시에는 주석 처리 또는 제거 필요
    if (session.getAttribute("userId") == null) {
        session.setAttribute("userId", "1"); // 임시 userId 설정 (1로 지정)
    }

    try {
        String postIdParam = request.getParameter("postId");
        String boardIdParam = request.getParameter("boardId");

        if (postIdParam != null && !postIdParam.isEmpty()) {
            postId = Integer.parseInt(postIdParam);
        } else {
            out.println("<p>잘못된 접근입니다. (postId 없음)</p>");
            return;
        }

        if (boardIdParam != null && !boardIdParam.isEmpty()) {
            boardId = Integer.parseInt(boardIdParam);
        } else {
            out.println("<p>잘못된 접근입니다. (boardId 없음)</p>");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        PreparedStatement postStmt = null;
        ResultSet postRs = null;

        String postSql = "SELECT p.TITLE, p.CONTENT, u.NAME, p.CREATED_AT, p.RECOMMEND_CNT, p.SCRAP_CNT "
                       + "FROM POSTS p JOIN USERS u ON p.USER_ID = u.USER_ID WHERE POST_ID = ?";
        postStmt = conn.prepareStatement(postSql);
        postStmt.setInt(1, postId);
        postRs = postStmt.executeQuery();

        if (postRs.next()) {
            String title = postRs.getString("TITLE");
            String content = postRs.getString("CONTENT");
            String author = "익명";
            String createdAt = postRs.getString("CREATED_AT");
            int recommendCnt = postRs.getInt("RECOMMEND_CNT");
            int scrapCnt = postRs.getInt("SCRAP_CNT");
%>

<div class="post-title"><%= title %></div>
<div class="post-info">
    <span><%= author %></span> | <span><%= createdAt %></span>
</div>
<div class="post-content"><%= content %></div>

<div>
    <!-- 추천 기능 -->
    <form action="/board/boardRecommend.jsp" method="post" id="recommendForm">
        <input type="hidden" name="POST_ID" value="<%= postId %>">
        <input type="hidden" name="USER_ID" value="<%= userId %>">
        <input type="hidden" name="BOARD_ID" value="<%= BoardUtil.getBoardId(request) %>">
        <button type="submit" class="reaction">공감 (<span id="recommendCount"><%= recommendCnt %></span>)</button>
    </form>
</div>

<a href="/board/boardList.jsp?boardId=<%= boardId %>" class="back-button">글 목록</a>

<%
        }
    } catch (NumberFormatException e) {
        out.println("<p>올바르지 않은 게시글 번호 또는 게시판 번호입니다.</p>");
    } catch (Exception e) {
        out.println("오류: " + e.getMessage());
    } finally {
        if (conn != null) try { conn.close(); } catch (Exception e) { e.printStackTrace(); }
    }
%>

</body>
</html>