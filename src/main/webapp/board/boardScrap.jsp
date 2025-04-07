<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    String boardIdParam = request.getParameter("BOARD_ID");

    int boardId = 0;
    try {
        boardId = Integer.parseInt(boardIdParam);
    } catch (NumberFormatException e) {
        out.println("잘못된 boardId 값: " + boardIdParam);
        return;
    }
    
    try {
        // 스크랩 여부 확인
        String checkSql = "SELECT * FROM SCRAPS WHERE POST_ID = ? AND USER_ID = ?";
        pstmtCheck = conn.prepareStatement(checkSql);
        pstmtCheck.setString(1, postId);
        pstmtCheck.setInt(2, userId);
        rsCheck = pstmtCheck.executeQuery();

        if (rsCheck.next()) {
            // 이미 스크랩한 경우 -> 스크랩 취소
            String deleteSql = "DELETE FROM SCRAPS WHERE POST_ID = ? AND USER_ID = ?";
            pstmtDelete = conn.prepareStatement(deleteSql);
            pstmtDelete.setString(1, postId);
            pstmtDelete.setInt(2, userId);
            pstmtDelete.executeUpdate();

            // 스크랩 수 감소
            String updateSql = "UPDATE POSTS SET SCRAP_CNT = SCRAP_CNT - 1 WHERE POST_ID = ?";
            pstmtUpdate = conn.prepareStatement(updateSql);
            pstmtUpdate.setString(1, postId);
            pstmtUpdate.executeUpdate();
        } else {
            // 스크랩하지 않은 경우 -> 스크랩 추가
            String insertSql = "INSERT INTO SCRAPS (POST_ID, USER_ID, BOARD_ID, SCRAP_DATE) VALUES (?, ?, ?, NOW())";
            pstmtInsert = conn.prepareStatement(insertSql);
            pstmtInsert.setString(1, postId);
            pstmtInsert.setInt(2, userId);
            pstmtInsert.setInt(3, boardId);
            pstmtInsert.executeUpdate();

            // 스크랩 수 증가
            String updateSql = "UPDATE POSTS SET SCRAP_CNT = SCRAP_CNT + 1 WHERE POST_ID = ?";
            pstmtUpdate = conn.prepareStatement(updateSql);
            pstmtUpdate.setString(1, postId);
            pstmtUpdate.executeUpdate();
        }

        // 스크랩 후 게시글 보기 페이지로 리다이렉트 (boardId 포함)
        response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);

    } catch (Exception e) {
        out.println("스크랩 처리 중 오류: " + e.getMessage());
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
