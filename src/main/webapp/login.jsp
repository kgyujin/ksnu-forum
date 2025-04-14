<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>군산대 커뮤니티 로그인</title>
    <link rel="stylesheet" href="/common/css/login.css" />
</head>
<body>
    <div class="login-container">
		<div class="logo-wrapper">
            <img src="/images/logo.jpg" alt="로고" class="logo-image">
        </div>
    
        <h2 class="title">군산대학교 커뮤니티 로그인</h2>
        <form action="LoginServlet" method="post" class="login-form">
            <input type="text" name="userId" placeholder="학번" required />
            <input type="password" name="password" placeholder="비밀번호" required />
            <input type="submit" value="로그인" class="login-btn" />
        </form>
        <div class="link-box">
            <a href="register.jsp">회원가입</a>
        </div>
    </div>
</body>
</html>