<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<%
    PreparedStatement pstmtCheck = null;
    PreparedStatement pstmtInsert = null;
    PreparedStatement pstmtDelete = null;
    PreparedStatement pstmtUpdate = null;
    ResultSet rsCheck = null;

    String postId = request.getParameter("POST_ID");
    String userId = request.getParameter("USER_ID");
    String boardIdParam = request.getParameter("BOARD_ID");

    // BoardUtil을 사용하여 boardId를 정확히 가져옴
    int boardId = 0;
    try {
        boardId = Integer.parseInt(boardIdParam);
    } catch (NumberFormatException e) {
        out.println("잘못된 boardId 값: " + boardIdParam);
        return;
    }

    try {
        // 추천 여부 확인
        String checkSql = "SELECT * FROM RECOMMENDS WHERE POST_ID = ? AND USER_ID = ?";
        pstmtCheck = conn.prepareStatement(checkSql);
        pstmtCheck.setString(1, postId);
        pstmtCheck.setString(2, userId);
        rsCheck = pstmtCheck.executeQuery();

        if (rsCheck.next()) {
            // 이미 추천한 경우 -> 추천 취소
            String deleteSql = "DELETE FROM RECOMMENDS WHERE POST_ID = ? AND USER_ID = ?";
            pstmtDelete = conn.prepareStatement(deleteSql);
            pstmtDelete.setString(1, postId);
            pstmtDelete.setString(2, userId);
            pstmtDelete.executeUpdate();

            // 추천 수 감소
            String updateSql = "UPDATE POSTS SET RECOMMEND_CNT = RECOMMEND_CNT - 1 WHERE POST_ID = ?";
            pstmtUpdate = conn.prepareStatement(updateSql);
            pstmtUpdate.setString(1, postId);
            pstmtUpdate.executeUpdate();
        } else {
            // 추천하지 않은 경우 -> 추천 추가
            String insertSql = "INSERT INTO RECOMMENDS (POST_ID, USER_ID, BOARD_ID, REC_DATE) VALUES (?, ?, ?, NOW())";
            pstmtInsert = conn.prepareStatement(insertSql);
            pstmtInsert.setString(1, postId);
            pstmtInsert.setString(2, userId);
            pstmtInsert.setInt(3, boardId);  // BOARD_ID 추가
            pstmtInsert.executeUpdate();

            // 추천 수 증가
            String updateSql = "UPDATE POSTS SET RECOMMEND_CNT = RECOMMEND_CNT + 1 WHERE POST_ID = ?";
            pstmtUpdate = conn.prepareStatement(updateSql);
            pstmtUpdate.setString(1, postId);
            pstmtUpdate.executeUpdate();
        }

        // 추천 후 게시글 보기 페이지로 리다이렉트 (boardId 포함)
        response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);

    } catch (Exception e) {
        out.println("오류: " + e.getMessage());
    } finally {
        try {
            if (rsCheck != null) rsCheck.close();
            if (pstmtCheck != null) pstmtCheck.close();
            if (pstmtInsert != null) pstmtInsert.close();
            if (pstmtDelete != null) pstmtDelete.close();
            if (pstmtUpdate != null) pstmtUpdate.close();
            if (conn != null) conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
