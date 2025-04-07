<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ include file="/common/header.jsp" %>

<%
    // 세션 무효화
    session = request.getSession(false);
    if (session != null) {
        session.invalidate();
    }
    // 로그아웃 후 로그인 페이지로 이동
    response.sendRedirect(request.getContextPath() + "/login.jsp");
%>
