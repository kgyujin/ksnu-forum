package com.ksnu.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.util.Properties;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteAccountServlet")
public class DeleteAccountServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession(false);

        // 세션 유효성 검사
        if (session == null || session.getAttribute("userId") == null) {
            out.println("<script>alert('로그인이 필요합니다.'); location.href='index.jsp';</script>");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        Connection conn = null;
        PreparedStatement pstmt = null;

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

            // 자동 커밋 비활성화
            conn.setAutoCommit(false);

            // 1. 사용자의 탈퇴 상태를 'Y'로 업데이트
            String updateUserSql = "UPDATE users SET IS_DELETED = 'Y' WHERE USER_ID = ?";
            pstmt = conn.prepareStatement(updateUserSql);
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
            pstmt.close();

            // 트랜잭션 커밋
            conn.commit();

            // 탈퇴 후 세션 무효화
            session.invalidate();
            out.println("<script>alert('회원 탈퇴가 완료되었습니다.'); location.href='index.jsp';</script>");

        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (Exception rollbackEx) {
                rollbackEx.printStackTrace();
            }
            e.printStackTrace();
            out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.go(-1);</script>");
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}
