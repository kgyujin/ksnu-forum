<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>로그인</title>
</head>
<body>
    <h2>로그인</h2>
   <form action="LoginServlet" method="post">
    학번: <input type="text" name="userid" required><br>   <%-- 수정됨 --%>
    비밀번호: <input type="password" name="password" required><br>
    <input type="submit" value="로그인">
</form>

    <a href="register.jsp">회원가입</a>
</body>
</html>
