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
public class LoginServlet extends HttpServlet
{
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String stdNum = request.getParameter("userId");
        String password = request.getParameter("password");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try
        {
            InputStream input = getServletContext().getResourceAsStream("/WEB-INF/config.properties");
            Properties props = new Properties();
            props.load(input);

            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String dbUser = props.getProperty("db.user");
            String dbPass = props.getProperty("db.password");

            Class.forName(driver);
            conn = DriverManager.getConnection(url, dbUser, dbPass);

            // 1. 해당 학번이 존재하는지 먼저 확인
            String checkSql = "SELECT PASSWORD, IS_DELETED, USER_ID FROM users WHERE STD_NUM = ?";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, stdNum);
            rs = pstmt.executeQuery();

            if (!rs.next())
            {
                out.println("<script>alert('존재하지 않는 학번입니다.'); history.back();</script>");
                return;
            }

            String dbPassword = rs.getString("PASSWORD");
            String isDeleted = rs.getString("IS_DELETED");
            int userId = rs.getInt("USER_ID");

            if ("Y".equalsIgnoreCase(isDeleted))
            {
                out.println("<script>alert('탈퇴한 계정입니다. 로그인이 불가능합니다.'); history.back();</script>");
                return;
            }

            if (!dbPassword.equals(password))
            {
                out.println("<script>alert('비밀번호가 일치하지 않습니다.'); history.back();</script>");
                return;
            }

            // 로그인 성공
            HttpSession session = request.getSession();
            session.setAttribute("userId", userId);

            out.println("<script>location.href='index.jsp';</script>");
        }
        catch (Exception e)
        {
            e.printStackTrace();
            out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.back();</script>");
        }
        finally
        {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}
