package com.ksnu.util;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/RegisterServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // 파일 저장 경로 (서버 내부에 저장)
    private static final String UPLOAD_DIR = "uploads";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // 파일 저장 경로 설정
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        try {
            // 회원 정보 가져오기
            String userId = request.getParameter("userid");
            String password = request.getParameter("password");
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String stdNum = request.getParameter("std_num");

            // 파일 업로드 처리
            Part filePart = request.getPart("certificate");
            String fileName = filePart.getSubmittedFileName();
            String filePath = uploadPath + File.separator + fileName;
            filePart.write(filePath);

            // 데이터베이스에 회원 정보 저장
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ksnu_forum", "root", "your_password");

            String sql = "INSERT INTO users (STD_NUM, PASSWORD, NAME, EMAIL, CERTIFICATE_PATH, REG_DATE) VALUES (?, ?, ?, ?, ?, NOW())";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, stdNum);
            pstmt.setString(2, password); // 실제로는 비밀번호 해싱 필요
            pstmt.setString(3, name);
            pstmt.setString(4, email);
            pstmt.setString(5, filePath);

            int row = pstmt.executeUpdate();
            if (row > 0) {
                out.println("<script>alert('회원가입 성공!'); location.href='login.jsp';</script>");
            } else {
                out.println("<script>alert('회원가입 실패!'); history.go(-1);</script>");
            }
            pstmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('오류 발생: " + e.getMessage() + "'); history.go(-1);</script>");
        }
    }
}
