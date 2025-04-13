<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <title>게시글 보기</title>
    <meta charset="UTF-8">
    <style>
		/* boardView.jsp에 추가할 스타일 */
		.container {
		    max-width: 800px;
		    margin: 30px auto;
		    padding: 30px;
		    background-color: #fff;
		    border-radius: 8px;
		    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
		}
		
		.post-title {
		    font-size: 24px;
		    font-weight: bold;
		    color: #20409a;
		    margin-bottom: 15px;
		    padding-bottom: 15px;
		    border-bottom: 1px solid #f0f0f0;
		}
		
		.post-info {
		    color: #666;
		    font-size: 14px;
		    margin-bottom: 25px;
		    display: flex;
		    align-items: center;
		}
		
		.post-info span {
		    margin-right: 15px;
		}
		
		.post-content {
		    line-height: 1.8;
		    margin-bottom: 30px;
		    font-size: 16px;
		    color: #333;
		}
		
		/* 반응 버튼 영역 스타일 수정 - 가로 배치 */
		.reaction-buttons {
		    display: flex;
		    flex-direction: row;
		    gap: 10px;
		    margin-bottom: 30px; /* 댓글 섹션과의 간격 */
		    padding-bottom: 20px;
		    border-bottom: 1px solid #eee;
		}
		
		.reaction {
		    display: inline-flex;
		    align-items: center;
		    justify-content: center;
		    /* background-color: #f8f9fa; */
		    color: #333;
		    border: 1px solid #e0e0e0;
		    padding: 10px 20px;
		    border-radius: 4px;
		    cursor: pointer;
		    transition: all 0.2s;
		    font-weight: 500;
		}
		
		.reaction:hover {
		    background-color: #e9ecef;
		    transform: translateY(-2px);
		}
		
		.comment-section {
		    margin-top: 40px; /* 반응 버튼과의 간격 증가 */
		}
		
		.comment-section h3 {
		    font-size: 18px;
		    color: #20409a;
		    margin-bottom: 20px;
		    font-weight: 600;
		}
		
		.comment-input {
		    width: 100%;
		    padding: 12px;
		    border: 1px solid #ddd;
		    border-radius: 8px;
		    resize: vertical;
		    min-height: 80px;
		    margin-bottom: 15px;
		    font-family: inherit;
		    transition: border-color 0.2s;
		}
		
		.comment-input:focus {
		    border-color: #20409a;
		    outline: none;
		}
		
		.comment-section button {
		    background-color: #20409a;
		    color: white;
		    border: none;
		    padding: 8px 16px;
		    border-radius: 4px;
		    cursor: pointer;
		    transition: background-color 0.2s;
		    font-weight: 500;
		}
		
		.comment-section button:hover {
		    background-color: #163172;
		}
		
		/* 댓글 아이템 스타일 개선 */
		.comment-item {
		    background-color: #f8f9fa;
		    border-radius: 8px;
		    padding: 15px;
		    margin-bottom: 20px; /* 댓글 간 간격 증가 */
		    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
		}
		
		/* 댓글 관련 버튼 스타일 */
		.comment-actions {
		    display: inline-flex;
		    align-items: center;
		    margin-top: 8px;
		    margin-left: 0;
		}
		
		.comment-actions a, .reply-button {
		    background-color: #f0f0f0;
		    color: #666;
		    border: none;
		    padding: 5px 10px;
		    border-radius: 4px;
		    font-size: 12px;
		    margin-right: 8px;
		    cursor: pointer;
		    text-decoration: none;
		    transition: all 0.2s;
		}
		
		.comment-actions a:hover, .reply-button:hover {
		    background-color: #e0e0e0;
		    transform: translateY(-1px);
		}
		
		.comment-actions a.edit-link {
		    color: #20409a;
		}
		
		.comment-actions a.delete-link {
		    color: #dc3545;
		}
		
		/* 대댓글 버튼 스타일 - 수정/삭제 버튼과 함께 배치 */
		.reply-button {
		    background-color: #f0f0f0;
		    color: #666;
		}
		
		/* 대댓글 폼 스타일 */
		.reply-form {
		    margin: 10px 0 10px 30px;
		    padding-left: 10px;
		    border-left: 2px solid #ddd;
		}
		
		/* 대댓글 스타일 개선 - 들여쓰기와 시각적 구분 */
		.comment-item.comment-reply {
		    margin-left: 40px; /* 들여쓰기 증가 */
		    padding-left: 15px;
		    border-left: 3px solid #20409a;
		    background-color: #f0f4fa; /* 약간 다른 배경색 */
		    margin-top: 15px;
		    margin-bottom: 20px; /* 간격 증가 */
		    border-radius: 0 8px 8px 0;
		}
		
		/* 대댓글 폼 스타일 개선 */
		#replyForm {
		    margin: 10px 0 10px 30px;
		    padding: 15px;
		    background-color: #f8f9fa;
		    border-left: 3px solid #20409a;
		    border-radius: 0 4px 4px 0;
		    transition: all 0.3s ease;
		}
		
		/* 글 목록 버튼 스타일 개선 */
		.back-button, .edit-button, .delete-button {
		    display: inline-block;
		    padding: 10px 20px;
		    border-radius: 4px;
		    text-decoration: none;
		    font-weight: 600;
		    transition: all 0.3s ease;
		    margin-right: 10px;
		    margin-top: 20px;
		    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
		}
		
		.back-button {
		    background-color: #20409a;
		    color: white;
		    border: none;
		}
		
		.back-button:hover {
		    background-color: #163172;
		    transform: translateY(-2px);
		    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
		}
		
		.edit-button {
		    background-color: #28a745;
		    color: white;
		    border: none;
		}
		
		.edit-button:hover {
		    background-color: #218838;
		    transform: translateY(-2px);
		    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
		}
		
		.delete-button {
		    background-color: #dc3545;
		    color: white;
		    border: none;
		}
		
		.delete-button:hover {
		    background-color: #c82333;
		    transform: translateY(-2px);
		    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
		}
		
		/* 대댓글 입력 폼 개선 */
		#replyForm[id^="replyForm"] {
		    margin: 15px 0 15px 40px;
		    padding: 15px;
		    background-color: #f0f4fa;
		    border-left: 3px solid #20409a;
		    border-radius: 0 8px 8px 0;
		    animation: fadeIn 0.3s ease;
		    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
		}
		
		@keyframes fadeIn {
		    from { opacity: 0; transform: translateY(-10px); }
		    to { opacity: 1; transform: translateY(0); }
		}
    </style>
</head>
<body>
<div class="container">
<%
    int postId = 0;
    int boardId = 0;
    int authorId = 0;

    try {
        // 세션에서 로그인한 사용자 ID 가져오기
        if (session.getAttribute("userId") != null) {
            userId = (int) session.getAttribute("userId");
        }

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

        PreparedStatement postStmt = null;
        ResultSet postRs = null;

        // 게시글 정보와 작성자 ID 가져오기
        String postSql = "SELECT p.TITLE, p.CONTENT, u.NAME, p.CREATED_AT, p.RECOMMEND_CNT, p.SCRAP_CNT, p.USER_ID, u.IS_DELETED "
                + "FROM POSTS p LEFT JOIN USERS u ON p.USER_ID = u.USER_ID WHERE POST_ID = ?";
        postStmt = conn.prepareStatement(postSql);
        postStmt.setInt(1, postId);
        postRs = postStmt.executeQuery();

        if (postRs.next()) {
            String title = postRs.getString("TITLE");
            String content = postRs.getString("CONTENT");
            String author = "";
            String createdAt = postRs.getString("CREATED_AT");
            String isDeleted = postRs.getString("IS_DELETED");
            int recommendCnt = postRs.getInt("RECOMMEND_CNT");
            int scrapCnt = postRs.getInt("SCRAP_CNT");
            authorId = postRs.getInt("USER_ID"); // 작성자 ID 할당
            
            if ("Y".equals(isDeleted) || author == null) {
                author = "(알 수 없음)";
            } else {
                author = "익명";
            }
%>

<div class="post-title"><%= title %></div>
<div class="post-info">
    <span>익명</span>|　<span><%= createdAt %></span>
</div>
<div class="post-content"><%= content %></div>
<%
    String sql = "SELECT IMAGE_PATH FROM post_images WHERE POST_ID = ?";
    PreparedStatement stmt = conn.prepareStatement(sql);
    stmt.setInt(1, postId);
    ResultSet rs = stmt.executeQuery();
    while (rs.next()) {
        String imagePath = rs.getString("IMAGE_PATH");
%>
    <div>
        <!-- 이미지 경로 수정: 서버 경로를 포함한 URL로 설정 -->
        <img src="<%= request.getContextPath() + "/" + imagePath %>" alt="첨부 이미지" style="max-width: 200px;">
    </div>
<%
    }
    rs.close();
    stmt.close();
%>
<div class="comment-section">
	<div class="reaction-buttons">
	    <!-- 추천 기능 -->
	    <form action="/board/boardRecommend.jsp" method="post" id="recommendForm">
	        <input type="hidden" name="POST_ID" value="<%= postId %>">
	        <input type="hidden" name="USER_ID" value="<%= userId %>">
	        <input type="hidden" name="BOARD_ID" value="<%= boardId %>">
	        <button type="submit" class="reaction">공감 (<span id="recommendCount"><%= recommendCnt %></span>)</button>
		</form>
		
		<!-- 스크랩 기능 -->
	    <form action="/board/boardScrap.jsp" method="post" id="scrapForm">
	        <input type="hidden" name="POST_ID" value="<%= postId %>">
	        <input type="hidden" name="USER_ID" value="<%= userId %>">
	        <input type="hidden" name="BOARD_ID" value="<%= boardId %>">
	        <button type="submit" class="reaction">스크랩 (<span id="scrapCount"><%= scrapCnt %></span>)</button>
		</form>
	</div>
	
    <h3>댓글</h3>
    <form action="/board/addComment.jsp" method="post">
        <input type="hidden" name="postId" value="<%= postId %>">
        <input type="hidden" name="boardId" value="<%= boardId %>">
        <textarea name="content" class="comment-input" placeholder="댓글을 작성하세요." required></textarea>
        <button type="submit">댓글 작성</button>
    </form>
	<div class="comment-section">
		<%
		    Map<Integer, Integer> anonymousMap = new LinkedHashMap<>();
		    int anonymousCount = 1;
		
		    anonymousMap.put(authorId, 0); // 글쓴이는 항상 "익명(글쓴이)"로 표시
		    
		    // 첫 번째 쿼리: 모든 댓글을 생성 시간순으로 조회하여 익명 번호 부여
		    String allCommentsSql = "SELECT USER_ID, CREATED_AT FROM comments WHERE POST_ID = ? ORDER BY CREATED_AT ASC";
		    PreparedStatement allCommentsStmt = conn.prepareStatement(allCommentsSql);
		    allCommentsStmt.setInt(1, postId);
		    ResultSet allCommentsRs = allCommentsStmt.executeQuery();
		    
		    // 시간순으로 익명 번호 할당
		    while (allCommentsRs.next()) {
		        int commentUserId = allCommentsRs.getInt("USER_ID");
		        if (commentUserId != authorId && !anonymousMap.containsKey(commentUserId)) {
		            anonymousMap.put(commentUserId, anonymousCount++);
		        }
		    }
		    allCommentsRs.close();
		    allCommentsStmt.close();
		
		    // 두 번째 쿼리: 부모 댓글만 조회
		            String parentCommentSql = "SELECT c.COMMENT_ID, c.USER_ID, c.CONTENT, c.CREATED_AT, c.PARENT_ID, c.deleted, u.IS_DELETED "
	                                + "FROM comments c LEFT JOIN users u ON c.USER_ID = u.USER_ID "
	                                + "WHERE c.POST_ID = ? AND c.PARENT_ID = 0 ORDER BY c.CREATED_AT ASC";
	        PreparedStatement parentStmt = conn.prepareStatement(parentCommentSql);
	        parentStmt.setInt(1, postId);
	        ResultSet parentRs = parentStmt.executeQuery();
	
	        while (parentRs.next()) {
	            int parentCommentId = parentRs.getInt("COMMENT_ID");
	            int parentUserId = parentRs.getInt("USER_ID");
	            String parentContent = parentRs.getString("CONTENT");
	            String parentDate = parentRs.getString("CREATED_AT");
	            String parentDeleted = parentRs.getString("deleted");
	            String parentIsDeleted = parentRs.getString("IS_DELETED");
	            String parentCommenter = "";
	            String commenterStyle = "";
	
	            if ("Y".equals(parentDeleted)) {
	                parentContent = "삭제된 댓글입니다.";
	                parentCommenter = "(삭제)";
	                commenterStyle = "style='color:gray;'";
	            } else {
	                if ("Y".equals(parentIsDeleted)) {
	                    parentCommenter = "(알 수 없음)";
	                } else if (parentUserId == authorId) {
	                    parentCommenter = "익명(글쓴이)";
	                } else {
	                    if (!anonymousMap.containsKey(parentUserId)) {
	                        anonymousMap.put(parentUserId, anonymousCount++);
	                    }
	                    parentCommenter = "익명" + anonymousMap.get(parentUserId);
	                }
	            }
		%>
	    <div class="comment-item">
		    <strong <%= commenterStyle %>><%= parentCommenter %></strong>: <%= parentContent %> <span>(<%= parentDate %>)</span>
		    <div class="comment-actions">
		        <% if (parentUserId == userId && !"Y".equals(parentDeleted)) { %>
		            <a href="/board/editComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= parentCommentId %>" class="edit-link">수정</a>
		            <a href="/board/deleteComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= parentCommentId %>" onclick="return confirm('댓글을 삭제하시겠습니까?')" class="delete-link">삭제</a>
		        <% } %>
		        <button class="reply-button" onclick="showReplyForm(<%= parentCommentId %>)">대댓글</button>
		    </div>
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
            // 대댓글 조회
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
                String replyCommenter = "";
                commenterStyle = "";

                if ("Y".equals(replyDeleted)) {
                    replyContent = "삭제된 댓글입니다.";
                    replyCommenter = "(삭제)";
                    commenterStyle = "style='color:gray;'";
                } else {
                    if ("Y".equals(parentIsDeleted)) {
                        replyCommenter = "(알 수 없음)";
                    } else if (replyUserId == authorId) {
                        replyCommenter = "익명(글쓴이)";
                    } else {
                        if (!anonymousMap.containsKey(replyUserId)) {
                            anonymousMap.put(replyUserId, anonymousCount++);
                        }
                        replyCommenter = "익명" + anonymousMap.get(replyUserId);
                    }
                }
		%>
	    <div class="comment-item comment-reply">
		    <strong <%= commenterStyle %>><%= replyCommenter %></strong>: <%= replyContent %> <span>(<%= replyDate %>)</span>
		    <div class="comment-actions">
		        <% if (replyUserId == userId && !"Y".equals(replyDeleted)) { %>
		            <a href="/board/editComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= replyCommentId %>" class="edit-link">수정</a>
		            <a href="/board/deleteComment.jsp?postId=<%= postId %>&boardId=<%= boardId %>&commentId=<%= replyCommentId %>" onclick="return confirm('댓글을 삭제하시겠습니까?')" class="delete-link">삭제</a>
		        <% } %>
		    </div>
		</div>
		<%
            }
            replyRs.close();
            replyStmt.close();
        %>
    </div>
	<%
	    }
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

<script>
function showReplyForm(commentId) {
    const replyForm = document.getElementById("replyForm" + commentId);
    replyForm.style.display = replyForm.style.display === "none" ? "block" : "none";
}
</script>
</div>
</body>
</html>