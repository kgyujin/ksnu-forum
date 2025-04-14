<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>게시글 보기</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Pretendard', sans-serif;
            background-color: #f9f9f9;
        }

        .container {
            max-width: 800px;
            margin: 40px auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }

        .post-title {
            font-size: 24px;
            font-weight: bold;
            color: #20409a;
            margin-bottom: 15px;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
        }

        .post-info {
            font-size: 14px;
            color: #666;
            margin-bottom: 25px;
        }

        .post-content {
            font-size: 16px;
            line-height: 1.8;
            color: #333;
            margin-bottom: 20px;
        }

        .reaction-buttons {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
        }

        .reaction {
            background-color: #fff;
            border: 1px solid #ddd;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
            margin-bottom: 15px;
        }
        .reaction:hover {
            background-color: #f1f1f1;
        }

        .comment-section {
            margin-top: 40px;
        }

        .comment-section h3 {
            font-size: 18px;
            color: #20409a;
            margin-bottom: 15px;
        }

        .comment-item {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
        }

        .comment-item.comment-reply {
            margin-left: 40px;
            background-color: #f0f4fa;
            border-left: 3px solid #20409a;
        }

        .comment-actions {
            margin-top: 8px;
        }

        .comment-actions a, .comment-actions button {
            background-color: #eee;
            border: none;
            padding: 5px 10px;
            font-size: 12px;
            border-radius: 4px;
            text-decoration: none;
            margin-right: 8px;
            cursor: pointer;
        }

        .comment-input, .reply-form textarea {
            width: 100%;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #ccc;
            margin-bottom: 10px;
            resize: vertical;
        }

        .reply-form {
            display: none;
            margin-top: 10px;
            padding-left: 10px;
        }

        .reply-button {
            background-color: #f0f0f0;
        }

        .back-button, .edit-button, .delete-button {
            padding: 10px 20px;
            border-radius: 4px;
            font-weight: bold;
            color: #fff;
            text-decoration: none;
            margin-top: 10px;
            margin-right: 10px;
        }

        .back-button { background-color: #20409a; }
        .edit-button { background-color: #28a745; }
        .delete-button { background-color: #dc3545; }
    </style>
</head>
<body>
<div class="container">
<%
    int postId = 0;
    int boardId = 0;
    int authorId = 0;

    try {
        if (request.getParameter("postId") != null) {
            postId = Integer.parseInt(request.getParameter("postId"));
        }
        if (request.getParameter("boardId") != null) {
            boardId = Integer.parseInt(request.getParameter("boardId"));
        }

        String postSql = "SELECT p.TITLE, p.CONTENT, p.CREATED_AT, " +
                "       (SELECT COUNT(*) FROM RECOMMENDS r WHERE r.POST_ID = p.POST_ID) AS RECOMMEND_CNT, " +
                "       (SELECT COUNT(*) FROM SCRAPS s WHERE s.POST_ID = p.POST_ID) AS SCRAP_CNT, " +
                "       p.USER_ID, u.IS_DELETED " +
                "FROM POSTS p " +
                "LEFT JOIN USERS u ON p.USER_ID = u.USER_ID " +
                "WHERE p.POST_ID = ?";
		PreparedStatement postStmt = conn.prepareStatement(postSql);
		postStmt.setInt(1, postId);
		ResultSet postRs = postStmt.executeQuery();
		
		if (postRs.next()) 
		{
		   String title = postRs.getString("TITLE");
		   String content = postRs.getString("CONTENT");
		   String createdAt = postRs.getString("CREATED_AT");
		   int recommendCnt = postRs.getInt("RECOMMEND_CNT");
		   int scrapCnt = postRs.getInt("SCRAP_CNT");
		   authorId = postRs.getInt("USER_ID");
		   String authorIsDeleted = postRs.getString("IS_DELETED");
%>

<div class="post-title"><%= title %></div>
<div class="post-info">
    <%= "Y".equals(authorIsDeleted) ? "(알 수 없음)" : "익명" %> | <%= createdAt %>
</div>
<div class="post-content"><%= content %></div>

<%
    // 이미지 출력
    String imageSql = "SELECT IMAGE_PATH FROM post_images WHERE POST_ID = ?";
    PreparedStatement imgStmt = conn.prepareStatement(imageSql);
    imgStmt.setInt(1, postId);
    ResultSet imgRs = imgStmt.executeQuery();
    while (imgRs.next()) {
%>
    <img src="<%= request.getContextPath() + "/" + imgRs.getString("IMAGE_PATH") %>" style="max-width: 200px; margin-bottom: 15px;">
<%
    }
    imgRs.close();
    imgStmt.close();
%>

<div class="comment-section">
    <div class="reaction-buttons">
        <form action="/board/boardRecommend.jsp" method="post">
            <input type="hidden" name="POST_ID" value="<%= postId %>">
            <input type="hidden" name="USER_ID" value="<%= userId %>">
            <input type="hidden" name="BOARD_ID" value="<%= boardId %>">
            <button class="reaction" type="submit">공감 (<%= recommendCnt %>)</button>
        </form>
        <form action="/board/boardScrap.jsp" method="post">
            <input type="hidden" name="POST_ID" value="<%= postId %>">
            <input type="hidden" name="USER_ID" value="<%= userId %>">
            <input type="hidden" name="BOARD_ID" value="<%= boardId %>">
            <button class="reaction" type="submit">스크랩 (<%= scrapCnt %>)</button>
        </form>
    </div>

    <h3>댓글</h3>
    <form action="/board/addComment.jsp" method="post">
        <input type="hidden" name="postId" value="<%= postId %>">
        <input type="hidden" name="boardId" value="<%= boardId %>">
        <textarea name="content" class="comment-input" placeholder="댓글을 작성하세요." required></textarea>
        <button type="submit" class="reaction">댓글 작성</button>
    </form>

    <%
        // 1. 익명 매핑을 저장할 Map 생성 - 작성자는 0번으로 고정
        Map<Integer, Integer> anonymousMap = new LinkedHashMap<>();
        int anonymousCount = 1;
        
        // 2. 사용자 ID와 삭제 여부를 함께 저장할 Map 생성
        Map<Integer, Boolean> userDeletedMap = new HashMap<>();
        
        // 글 작성자를 매핑에 추가
        anonymousMap.put(authorId, 0);
        userDeletedMap.put(authorId, "Y".equals(authorIsDeleted));

        // 3. 모든 댓글 작성자 정보를 미리 조회
        String userSql = "SELECT c.USER_ID, u.IS_DELETED FROM comments c " +
                         "LEFT JOIN users u ON c.USER_ID = u.USER_ID " +
                         "WHERE c.POST_ID = ? ORDER BY c.CREATED_AT";
        PreparedStatement userStmt = conn.prepareStatement(userSql);
        userStmt.setInt(1, postId);
        ResultSet userRs = userStmt.executeQuery();
        
        while (userRs.next()) {
            int commentUserId = userRs.getInt("USER_ID");
            boolean isDeleted = "Y".equals(userRs.getString("IS_DELETED"));
            
            // 사용자 삭제 상태 저장
            userDeletedMap.put(commentUserId, isDeleted);
            
            // 익명 매핑 저장 (작성자가 아니고 아직 매핑되지 않은 경우에만)
            if (commentUserId != authorId && !anonymousMap.containsKey(commentUserId)) {
                anonymousMap.put(commentUserId, anonymousCount++);
            }
        }
        userRs.close();
        userStmt.close();

        // 4. 부모 댓글 조회 및 표시
        String parentSql = "SELECT c.COMMENT_ID, c.USER_ID, c.CONTENT, c.CREATED_AT, c.DELETED " +
                           "FROM comments c WHERE c.POST_ID = ? AND c.PARENT_ID = 0 ORDER BY c.CREATED_AT ASC";
        PreparedStatement parentStmt = conn.prepareStatement(parentSql);
        parentStmt.setInt(1, postId);
        ResultSet parentRs = parentStmt.executeQuery();
        
        while (parentRs.next()) {
            int commentId = parentRs.getInt("COMMENT_ID");
            int commentUserId = parentRs.getInt("USER_ID");
            String commentContent = parentRs.getString("CONTENT");
            String commentDate = parentRs.getString("CREATED_AT");
            String deleted = parentRs.getString("DELETED");
            boolean isDeletedUser = userDeletedMap.getOrDefault(commentUserId, false);
            
            String name = "";
            String style = "";

            if ("Y".equals(deleted)) {
                name = "(삭제)";
                commentContent = "삭제된 댓글입니다.";
                style = "style='color:gray;'";
            } else {
                if (isDeletedUser) {
                    name = "(알 수 없음)";
                } else if (commentUserId == authorId) {
                    name = "익명(글쓴이)";
                } else {
                    name = "익명" + anonymousMap.get(commentUserId);
                }
            }
    %>
        <div class="comment-item">
            <strong <%= style %>><%= name %></strong>: <%= commentContent %> <span>(<%= commentDate %>)</span>
            <div class="comment-actions">
                <% if (commentUserId == userId && !"Y".equals(deleted)) { %>
                    <a href="/board/editComment.jsp?commentId=<%= commentId %>&postId=<%= postId %>&boardId=<%= boardId %>" class="edit-link">수정</a>
                    <a href="/board/deleteComment.jsp?commentId=<%= commentId %>&postId=<%= postId %>&boardId=<%= boardId %>" class="delete-link" onclick="return confirm('삭제하시겠습니까?')">삭제</a>
                <% } %>
                <% if (!"Y".equals(deleted)) { %>
                    <button class="reply-button" onclick="showReplyForm(<%= commentId %>)">대댓글</button>
                <% } %>
            </div>
            <div id="replyForm<%= commentId %>" class="reply-form">
                <form action="/board/addComment.jsp" method="post">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    <input type="hidden" name="boardId" value="<%= boardId %>">
                    <input type="hidden" name="parentId" value="<%= commentId %>">
                    <textarea name="content" required></textarea>
                    <button type="submit" class="reaction">작성</button>
                </form>
            </div>
        </div>
    <%
        // 5. 해당 부모 댓글의 모든 대댓글 조회 및 표시
        String replySql = "SELECT c.COMMENT_ID, c.USER_ID, c.CONTENT, c.CREATED_AT, c.DELETED " +
                          "FROM comments c WHERE c.PARENT_ID = ? ORDER BY c.CREATED_AT ASC";
        PreparedStatement replyStmt = conn.prepareStatement(replySql);
        replyStmt.setInt(1, commentId);
        ResultSet replyRs = replyStmt.executeQuery();
        
        while (replyRs.next()) {
            int rId = replyRs.getInt("COMMENT_ID");
            int rUserId = replyRs.getInt("USER_ID");
            String rContent = replyRs.getString("CONTENT");
            String rDate = replyRs.getString("CREATED_AT");
            String rDeleted = replyRs.getString("DELETED");
            boolean rIsDeletedUser = userDeletedMap.getOrDefault(rUserId, false);
            
            String rName = "";
            style = "";

            if ("Y".equals(rDeleted)) {
                rContent = "삭제된 댓글입니다.";
                rName = "(삭제)";
                style = "style='color:gray;'";
            } else {
                if (rIsDeletedUser) {
                    rName = "(알 수 없음)";
                } else if (rUserId == authorId) {
                    rName = "익명(글쓴이)";
                } else {
                    rName = "익명" + anonymousMap.get(rUserId);
                }
            }
    %>
        <div class="comment-item comment-reply">
            <strong <%= style %>><%= rName %></strong>: <%= rContent %> <span>(<%= rDate %>)</span>
            <div class="comment-actions">
                <% if (rUserId == userId && !"Y".equals(rDeleted)) { %>
                    <a href="/board/editComment.jsp?commentId=<%= rId %>&postId=<%= postId %>&boardId=<%= boardId %>" class="edit-link">수정</a>
                    <a href="/board/deleteComment.jsp?commentId=<%= rId %>&postId=<%= postId %>&boardId=<%= boardId %>" class="delete-link" onclick="return confirm('삭제하시겠습니까?')">삭제</a>
                <% } %>
            </div>
        </div>
    <%
        }
        replyRs.close();
        replyStmt.close();
    } // end while parent
    parentRs.close();
    parentStmt.close();
    %>

    <div>
        <a href="/board/boardList.jsp?boardId=<%= boardId %>" class="back-button">글 목록</a>
        <% if (userId == authorId) { %>
            <a href="/board/boardUpdate.jsp?boardId=<%= boardId %>&postId=<%= postId %>" class="edit-button">수정</a>
            <a href="/board/boardDelete.jsp?boardId=<%= boardId %>&postId=<%= postId %>" class="delete-button">삭제</a>
        <% } %>
    </div>
</div>

<%
        }
    } catch (Exception e) {
        out.println("오류: " + e.getMessage());
    }
%>
</div>

<script>
function showReplyForm(commentId) {
    const form = document.getElementById("replyForm" + commentId);
    form.style.display = (form.style.display === "none" || form.style.display === "") ? "block" : "none";
}
</script>
</body>
</html>