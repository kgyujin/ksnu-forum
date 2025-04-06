<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/db/dbConnection.jsp" %>

<%
    int commentId = 0;
    int postId = 0;
    int boardId = 0;
    String content = "";

    try {
        // 댓글 ID와 게시글 ID, 게시판 ID 가져오기
        if (request.getParameter("commentId") != null) {
            commentId = Integer.parseInt(request.getParameter("commentId"));
        }
        if (request.getParameter("postId") != null) {
            postId = Integer.parseInt(request.getParameter("postId"));
        }
        if (request.getParameter("boardId") != null) {
            boardId = Integer.parseInt(request.getParameter("boardId"));
        }

        // GET 요청 처리: 기존 댓글 내용 불러오기
        if ("GET".equalsIgnoreCase(request.getMethod())) {
            if (request.getParameter("content") != null) {
                content = java.net.URLDecoder.decode(request.getParameter("content"), "UTF-8");
            } else {
                PreparedStatement stmt = null;
                ResultSet rs = null;
                try {
                    String sql = "SELECT CONTENT FROM comments WHERE COMMENT_ID = ?";
                    stmt = conn.prepareStatement(sql);
                    stmt.setInt(1, commentId);
                    rs = stmt.executeQuery();

                    if (rs.next()) {
                        content = rs.getString("CONTENT");
                    } else {
                        out.println("<p>댓글을 찾을 수 없습니다.</p>");
                        return;
                    }
                } catch (Exception e) {
                    out.println("오류: " + e.getMessage());
                } finally {
                    if (rs != null) try { rs.close(); } catch (Exception e) { e.printStackTrace(); }
                    if (stmt != null) try { stmt.close(); } catch (Exception e) { e.printStackTrace(); }
                }
            }
        }

        // POST 요청 처리: 수정된 댓글 내용 저장
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            content = request.getParameter("content");

            if (content == null || content.trim().isEmpty()) {
                out.println("<p>댓글 내용이 비어있습니다.</p>");
                return;
            }

            try {
                // 댓글 내용 업데이트 쿼리
                String updateSql = "UPDATE comments SET CONTENT = ?, UPDATED_AT = NOW() WHERE COMMENT_ID = ?";
                PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                updateStmt.setString(1, content);  // 수정된 댓글 내용 설정
                updateStmt.setInt(2, commentId);  // 수정할 댓글 ID 설정

                int result = updateStmt.executeUpdate();
                updateStmt.close();

                if (result > 0) {
                    // 수정 성공 시 게시글 페이지로 이동
                    response.sendRedirect("/board/boardView.jsp?postId=" + postId + "&boardId=" + boardId);
                } else {
                    out.println("<p>댓글 수정에 실패했습니다.</p>");
                }
            } catch (Exception e) {
                out.println("댓글 수정 오류: " + e.getMessage());
            }
        }
    } catch (NumberFormatException e) {
        out.println("<p>잘못된 요청입니다. (잘못된 번호 형식)</p>");
    } catch (Exception e) {
        out.println("댓글 수정 처리 오류: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>댓글 수정</title>
    <meta charset="UTF-8">
</head>
<body>
    <div>
        <h3>댓글 수정</h3>
        <form method="post">
            <textarea name="content" rows="4" maxlength="2000" required><%= content %></textarea>
            <button type="submit">수정 완료</button>
            <button type="button" onclick="location.href='/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>'">취소</button>
            <input type="hidden" name="boardId" value="<%= boardId %>">
            <input type="hidden" name="postId" value="<%= postId %>">
            <input type="hidden" name="commentId" value="<%= commentId %>">
        </form>
    </div>
</body>
</html>
