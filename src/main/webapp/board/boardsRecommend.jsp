<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>


<!-- RECOMMENDS 기능만	 -->
<%	
	PreparedStatement pstmtCheck = null;
	PreparedStatement pstmtInsert = null;
	PreparedStatement pstmtUpdate = null;
	ResultSet rsCheck = null;
	
    String postId = request.getParameter("POST_ID");
    String userId = request.getParameter("USER_ID");

   	try {
   		// 중복 방지
   		String checkSql = "SELECT * FROM RECOMMENTDS WHERE POST_ID = ? AND USER_ID = ?";
   		pstmtCheck = conn.prepareStatement(checkSql);
   		pstmtCheck.setString(1, postId);
   		pstmtCheck.setString(2, userId);
   		rsCheck = pstmtCheck.executeQuery();
   		
   		// 중복 X
   		if (!rsCheck.next()) {
   			String insertSql = "INSERT INTO RECOMMENDS (POST_ID, USER_ID, REC_DATE) VALUES (?, ?, NOW())";
   			pstmtInsert.setString(1, postId);
            pstmtInsert.setString(2, userId);
            pstmtInsert.executeUpdate();
            
            String updateSql = "UPDATE POSTS SET RECOMMEND_CNT = RECOMMEND_CNT + 1 WHERE POST_ID = ?";
            pstmtUpdate = conn.prepareStatement(updateSql);
            pstmtUpdate.setString(1, postId);
            pstmtUpdate.executeUpdate();
   		} else {
   			out.println("<script>alert('이미 추천한 게시글입니다!'); history.back();</script>");
   		}
   	} catch (Exception e) {
        out.println("오류: " + e.getMessage());
    } finally {
        if (rsCheck != null) rsCheck.close();
        if (pstmtCheck != null) pstmtCheck.close();
        if (pstmtInsert != null) pstmtInsert.close();
        if (pstmtUpdate != null) pstmtUpdate.close();
        if (conn != null) conn.close();
    }
%>

