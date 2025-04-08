<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>메인 페이지</title>
</head>
<body>
    <%
        String userId = (String) session.getAttribute("userId");
        if (userId != null) {
    %>
        <h2>로그인된 사용자: <%= userId %></h2>
    <%
        } else {
    %>
        <h2>로그인 정보가 없습니다. 다시 로그인하세요.</h2>
        <script>
            alert("로그인 세션이 없습니다. 로그인 페이지로 이동합니다.");
            location.href = "login.jsp";
            
            
            
            
            
            
            
            
        </script>
    <%
        }
    %>
</body>
</html>
