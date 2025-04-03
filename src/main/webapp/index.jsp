<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>

<%
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = "SELECT * FROM USERS";
%>

<h2>USERS 목록</h2>
<table border="1">
    <tr>
        <th>User ID</th>
        <th>Student Number</th>
        <th>Name</th>
        <th>Email</th>
    </tr>
<%
    try {
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            String userId = rs.getString("USER_ID");
            String stdNum = rs.getString("STD_NUM");
            String name = rs.getString("NAME");
            String email = rs.getString("EMAIL");
%>
    <tr>
        <td><%= userId %></td>
        <td><%= stdNum %></td>
        <td><%= name %></td>
        <td><%= email %></td>
    </tr>
<%
        }
    } catch (Exception e) {
        out.println("데이터 조회 오류: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
</table>