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
        .comment-section {
            margin-top: 20px;
            padding: 10px;
            border-top: 1px solid #ddd;
        }
        .comment-item {
            margin: 5px 0;
        }
        .comment-reply {
            margin-left: 20px;
        }
        .comment-input {
            width: 80%;
            padding: 8px;
            margin: 5px;
        }
        .reply-button {
            margin-left: 20px;
            font-size: 12px;
            cursor: pointer;
            color: blue;
        }
        .back-button, .edit-button {
            margin-top: 20px;
            background-color: red;
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            text-decoration: none;
        }
        .edit-button {
            margin-left: 10px;
            background-color: green;
        }
        
        .comment-reply {
	        margin-left: 30px;
	        padding-left: 10px;
	        border-left: 2px solid #ddd;
	    }
	    .deleted-comment {
	        color: gray;
	    }
    </style>
</head>
<body>

<%
    int postId = 0;
    int boardId = 0;
    int authorId = 0;

    // 테스트용 임시 userId 지정
    if (session.getAttribute("userId") == null) {
        session.setAttribute("userId", "1");
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

        String postSql = "SELECT p.TITLE, p.CONTENT, u.NAME, p.CREATED_AT, p.RECOMMEND_CNT, p.SCRAP_CNT, p.USER_ID "
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
            authorId = postRs.getInt("USER_ID");
%>

<div class="post-title"><%= title %></div>
<div class="post-info">
    <span><%= author %></span> | <span><%= createdAt %></span>
</div>
<div class="post-content"><%= content %></div>
<div class="comment-section">
    <!-- 추천 기능 -->
    <form action="/board/boardRecommend.jsp" method="post" id="recommendForm">
        <input type="hidden" name="POST_ID" value="<%= postId %>">
        <input type="hidden" name="USER_ID" value="<%= userId %>">
        <input type="hidden" name="BOARD_ID" value="<%= boardId %>">
        <button type="submit" class="reaction">공감 (<span id="recommendCount"><%= recommendCnt %></span>)</button>
	</form>
    <h3>댓글</h3>
    <form method="post" action="/board/addComment.jsp">
        <input type="hidden" name="postId" value="<%= postId %>">
        <input type="hidden" name="boardId" value="<%= boardId %>">
        <textarea name="content" class="comment-input" placeholder="댓글을 작성하세요." required></textarea>
        <button type="submit">댓글 작성</button>
    </form>
	<div class="comment-section">
	<%
	    // 부모 댓글 먼저 조회
	    String parentCommentSql = "SELECT COMMENT_ID, USER_ID, CONTENT, CREATED_AT, PARENT_ID, deleted "
	                            + "FROM comments WHERE POST_ID = ? AND PARENT_ID = 0 ORDER BY CREATED_AT ASC";
	    PreparedStatement parentStmt = conn.prepareStatement(parentCommentSql);
	    parentStmt.setInt(1, postId);
	    ResultSet parentRs = parentStmt.executeQuery();
	    int anonymousCount = 1;
	
	    while (parentRs.next()) {
	        int parentCommentId = parentRs.getInt("COMMENT_ID");
	        int parentUserId = parentRs.getInt("USER_ID");
	        String parentContent = parentRs.getString("CONTENT");
	        String parentDate = parentRs.getString("CREATED_AT");
	        String parentDeleted = parentRs.getString("deleted");
	        String parentCommenter = "";
	        String commenterStyle = "";
	
	        // 삭제된 댓글 처리
	        if ("Y".equals(parentDeleted)) {
	            parentContent = "삭제된 댓글입니다.";
	            parentCommenter = "(삭제)";
	            commenterStyle = "style='color:gray;'";
	        } else {
	            // 작성자 표시
	            parentCommenter = (parentUserId == authorId) ? "익명(글쓴이)" : "익명" + anonymousCount++;
	        }
	
	%>
	    <div class="comment-item">
		    <strong <%= commenterStyle %>><%= parentCommenter %></strong>: <%= parentContent %> <span>(<%= parentDate %>)</span>
		    <% if (parentUserId == Integer.parseInt(userId) && !"Y".equals(parentDeleted)) { %>
		        <a href="/board/editComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= parentCommentId %>&content=<%= java.net.URLEncoder.encode(parentContent, "UTF-8") %>">수정</a>
		        <a href="/board/deleteComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= parentCommentId %>" onclick="return confirm('댓글을 삭제하시겠습니까?')">삭제</a>
		    <% } %>
		    <button class="reply-button" onclick="showReplyForm(<%= parentCommentId %>)">대댓글</button>
		    <div id="replyForm<%= parentCommentId %>" style="display:none;">
		        <form method="post" action="/board/addComment.jsp">
		            <input type="hidden" name="postId" value="<%= postId %>">
		            <input type="hidden" name="boardId" value="<%= boardId %>">
		            <input type="hidden" name="parentId" value="<%= parentCommentId %>">
		            <textarea name="content" class="comment-input" placeholder="대댓글 작성" required></textarea>
		            <button type="submit">작성</button>
		        </form>
		    </div>
		</div>
	<%
	        // 부모 댓글의 대댓글 조회
	        String replySql = "SELECT COMMENT_ID, USER_ID, CONTENT, CREATED_AT, deleted "
	                        + "FROM comments WHERE PARENT_ID = ? ORDER BY CREATED_AT ASC";
	        PreparedStatement replyStmt = conn.prepareStatement(replySql);
	        replyStmt.setInt(1, parentCommentId);
	        ResultSet replyRs = replyStmt.executeQuery();
	
	        while (replyRs.next()) {
	            int replyCommentId = replyRs.getInt("COMMENT_ID");
	            int replyUserId = replyRs.getInt("USER_ID");
	            String replyContent = replyRs.getString("CONTENT");
	            String replyDate = replyRs.getString("CREATED_AT");
	            String replyDeleted = replyRs.getString("deleted");
	            String replyCommenter = (replyUserId == authorId) ? "익명(글쓴이)" : "익명" + anonymousCount++;
	
	            // 삭제된 대댓글 처리
	            if ("Y".equals(replyDeleted)) {
	                replyContent = "삭제된 댓글입니다.";
	                replyCommenter = "(삭제)";
	                commenterStyle = "style='color:gray;'";
	            }
	%>
	        <div class="comment-item comment-reply">
	            <strong <%= commenterStyle %>><%= replyCommenter %></strong>: <%= replyContent %> <span>(<%= replyDate %>)</span>
	            <% if (replyUserId == Integer.parseInt(userId) && !"Y".equals(replyDeleted)) { %>
	                <a href="/board/editComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= replyCommentId %>">수정</a>
	                <a href="/board/deleteComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= replyCommentId %>" onclick="return confirm('댓글을 삭제하시겠습니까?')">삭제</a>
	            <% } %>
	        </div>
	<%
	        }
	    }
	%>
	</div>
</div>
<div>
    <a href="/board/boardList.jsp?boardId=<%= boardId %>" class="back-button">글 목록</a>
    <% if (Integer.parseInt(userId) == authorId) { %>
        <a href="/board/boardUpdate.jsp?boardId=<%= boardId %>&postId=<%= postId %>" class="edit-button">수정</a>
    <% } %>
</div>

<%
        }
    } catch (Exception e) {
        out.println("오류: " + e.getMessage());
    }
%>

<script>
function showReplyForm(commentId) {
    const replyForm = document.getElementById("replyForm" + commentId);
    replyForm.style.display = replyForm.style.display === "none" ? "block" : "none";
}
</script>

</body>
</html>
