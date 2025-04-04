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
        PreparedStatement commentStmt = null;
        ResultSet postRs = null;
        ResultSet commentRs = null;

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
    <span class="reaction" id="recommendBtn">공감 (<span id="recommendCount"><%= recommendCnt %></span>)</span>
    <span class="reaction" id="scrapBtn">스크랩 (<span id="scrapCount"><%= scrapCnt %></span>)</span>
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

<script>
    const postId = <%= postId %>;

    function addComment() {
        const content = document.getElementById("commentInput").value;
        if (content.trim()) {
            // 자바스크립트에서 encodeURIComponent 사용
            const encodedContent = encodeURIComponent(content);
            fetch(`/api/addComment?postId=${postId}&content=${encodedContent}`, {
                method: 'POST'
            }).then(() => location.reload());
        } else {
            alert("댓글 내용을 입력해주세요.");
        }
    }

    function toggleReaction(type) {
        const button = document.getElementById(type + "Btn");
        const count = document.getElementById(type + "Count");
        button.classList.toggle("active");
        const isActive = button.classList.contains("active");
        count.innerText = parseInt(count.innerText) + (isActive ? 1 : -1);

        fetch(`/api/reaction?postId=${postId}&type=${type}&action=${isActive ? 'add' : 'remove'}`, {
            method: 'POST'
        });
    }

    document.getElementById("recommendBtn").onclick = () => toggleReaction("recommend");
    document.getElementById("scrapBtn").onclick = () => toggleReaction("scrap");
</script>

</body>
</html>
