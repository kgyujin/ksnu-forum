<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>회원가입</title>
</head>
<body>
    <h2>회원가입</h2>
    <form action="db/joinAction.jsp" method="post">
        학번: <input type="text" name="userId" required><br>
        비밀번호: <input type="password" name="password" required><br>
        이름: <input type="text" name="name" required><br>
        이메일: <input type="email" name="email" required><br>
        재학증명서 경로 (선택): <input type="text" name="certificatePath"><br>
        <input type="submit" value="회원가입">
    </form>
    <a href="login.jsp">로그인으로 돌아가기</a>
</body>
</html>