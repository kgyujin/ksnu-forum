<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String stdNum = request.getParameter("userId");
    String password = request.getParameter("password");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    // String certificatePath = request.getParameter("certificatePath");

    PreparedStatement pstmt = null;

    try {
        // 사용자 등록 SQL
        String sql = "INSERT INTO users (STD_NUM, PASSWORD, NAME, EMAIL) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        pstmt.setString(1, stdNum);
        pstmt.setString(2, password);
        pstmt.setString(3, name);
        pstmt.setString(4, email);
        // pstmt.setString(5, (certificatePath != null && !certificatePath.isEmpty()) ? certificatePath : null);

        int result = pstmt.executeUpdate();

        if (result > 0) {
            // 새로 생성된 USER_ID 가져오기
            ResultSet generatedKeys = pstmt.getGeneratedKeys();
            if (generatedKeys.next()) {
                int userId = generatedKeys.getInt(1);  // int로 가져옴
                session.setAttribute("userId", userId); // int로 세션에 저장
            }

            out.println("<script>alert('회원가입 성공! 로그인 페이지로 이동합니다.'); location.href='../login.jsp';</script>");
        } else {
            out.println("<script>alert('회원가입 실패'); history.back();</script>");
        }

    } catch (SQLIntegrityConstraintViolationException dup) {
        out.println("<script>alert('❌ 중복된 학번 또는 이메일입니다.'); history.back();</script>");
    } catch (Exception e) {
        out.println("<script>alert('에러 발생: " + e.getMessage() + "'); history.back();</script>");
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>