<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.Properties"%>

<%
	Connection conn = null;
	String sql = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	try {
		// config.properties 파일 경로 설정
		String configPath = application.getRealPath("/WEB-INF/config.properties");
		Properties props = new Properties();
		
		// 프로퍼티 파일 로드
		FileInputStream fis = new FileInputStream(configPath);
		props.load(fis);
		
		// 프로퍼티에서 DB 정보 가져오기
		String jdbcUrl = props.getProperty("db.url");
		String dbId = props.getProperty("db.user");
		String dbPass = props.getProperty("db.password");
		
		Class.forName("com.mysql.jdbc.Driver");
		conn = DriverManager.getConnection(jdbcUrl, dbId, dbPass);
		out.println("연결 성공");

		sql = "select * from USERS";
		pstmt = conn.prepareStatement(sql);
		rs = pstmt.executeQuery();
%>

<html>
<body>
    <h2>USERS 목록</h2>
    <table border="1">
        <tr>
            <th>User ID</th>
            <th>Student Number</th>
            <th>Name</th>
            <th>Email</th>
        </tr>
<%
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
%>
    </table>
</body>
</html>

<%
	} catch (Exception e) { 
		e.printStackTrace();
		out.println("연결 실패");
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
