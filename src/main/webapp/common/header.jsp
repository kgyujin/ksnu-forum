<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ksnu.util.SessionCheck" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page session="true" %>

<%
    if (!SessionCheck.isLoggedIn(session)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int userId = SessionCheck.getUserId(session);
    if (userId == -1) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <link href="/common/css/style.css" rel="stylesheet" type="text/css">
    <style>
        @font-face {
            font-family: 'Pretendard-Regular';
            src: url('https://fastly.jsdelivr.net/gh/Project-Noonnu/noonfonts_2107@1.1/Pretendard-Regular.woff') format('woff');
            font-weight: 400;
            font-style: normal;
        }

        /* 헤더 스타일 */
        .header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: 60px;
            background-color: #fff;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            align-items: center;
            padding-left: 20px;
            box-sizing: border-box;
            z-index: 1000;
            font-family: 'Pretendard';
        }

        .logo {
            display: flex;
            padding-left: 30px;
            align-items: center;
            gap: 10px;
        }

        .logo-text {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-left: 8px;
            display: flex;
            flex-direction: column;
            align-items: flex-start;
        }

        .logo-text span {
            color: #F29200;
            font-size: 12px;
            margin-bottom: -5px;
        }

        .logo img {
            height: 40px;
        }

        /* 로고를 누르면 홈으로 이동 */
        .logo a {
            text-decoration: none;
            color: inherit;
        }

        /* 본문 내용이 헤더에 가려지지 않도록 여백 추가 */
        body {
            margin: 0;
            padding-top: 60px; /* 고정 헤더 높이만큼 여백 추가 */
            box-sizing: border-box;
        }

        /* 컨테이너 전체 너비를 화면에 맞추기 */
        .container {
            /* max-width: 1200px; */
            margin: auto;
            padding: 20px;
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">
        <a href="/index.jsp">
            <img src="<%= request.getContextPath() %>/images/logo.jpg" alt="로고">
        </a>
        <div class="logo-text">
            <span style="padding-bottom: 3px;">커뮤니티</span>
            국립군산대
        </div>
    </div>
</div>

</body>
</html>
