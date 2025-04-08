package com.ksnu.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Properties;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        int userId = Integer.parseInt(request.getParameter("userId"));
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // 설정 파일 읽기
            InputStream input = getServletContext().getResourceAsStream("/WEB-INF/config.properties");
            Properties props = new Properties();
            props.load(input);

            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String dbUser = props.getProperty("db.user");
            String dbPass = props.getProperty("db.password");

            Class.forName(driver);
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            // 로그인 SQL 수정: USER_ID 조회
            String sql = "SELECT USER_ID FROM users WHERE STD_NUM = ? AND PASSWORD = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                userId = rs.getInt("USER_ID");  // int로 가져옴

                // 세션에 USER_ID를 int로 저장
                HttpSession session = request.getSession();
                session.setAttribute("userId", userId); // int로 저장

                out.println("<script>location.href='index.jsp';</script>");
            } else {
                out.println("<script>alert('입력한 학번 또는 비밀번호를 확인해주세요.'); history.go(-1);</script>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.go(-1);</script>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}
