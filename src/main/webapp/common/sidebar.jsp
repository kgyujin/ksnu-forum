<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="com.ksnu.util.SessionCheck" %>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<%
    String stdNum = "";
    String name = "";

    if (userId > 0) {
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT STD_NUM, NAME FROM users WHERE USER_ID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                stdNum = rs.getString("STD_NUM");
                name = rs.getString("NAME");
            }
        } catch (Exception e) {
            out.println("<script>alert('사용자 정보를 불러오는 중 오류 발생: " + e.getMessage() + "');</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
%>

<div style="width: 250px; background-color: #ddd; text-align: center; padding: 20px; border: 1px solid #ccc;">
    <img src="images/profile.png" alt="프로필 이미지" style="width: 100px; height: 100px; border-radius: 50%; object-fit: cover; margin-bottom: 10px;">
    <div style="color: gray; font-size: 20px;"><%= name %></div>
    <div style="color: gray; font-size: 16px; margin-bottom: 15px;"><%= stdNum %></div>
    
    <form action="LogoutServlet" method="post">
        <input type="submit" value="로그아웃" style="padding: 8px 16px; font-size: 16px; margin-bottom: 20px;">
    </form>

    <div style="background-color: white; padding: 0; border-top: 1px solid #fff;">
        <a href="myPosts.jsp" style="display: block; background-color: #ddd; padding: 15px 0; text-decoration: none; color: black; font-size: 20px;">내가 쓴 글</a>
        <a href="myComments.jsp" style="display: block; background-color: #ddd; padding: 15px 0; text-decoration: none; color: black; font-size: 20px;">댓글 단 글</a>
        <a href="myScraps.jsp" style="display: block; background-color: #ddd; padding: 15px 0; text-decoration: none; color: black; font-size: 20px;">내 스크랩</a>
    </div>
</div>
