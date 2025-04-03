package com.ksnu.service;

import java.sql.Connection;
import java.sql.PreparedStatement;

public class PostService {

    // 게시글 추가 메서드
    public static boolean addPost(Connection conn, int boardId, int userId, String title, String content) {
        String sql = "INSERT INTO POSTS (BOARD_ID, USER_ID, TITLE, CONTENT, CREATED_AT) VALUES (?, ?, ?, ?, NOW())";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, boardId);
            pstmt.setInt(2, userId);
            pstmt.setString(3, title);
            pstmt.setString(4, content);
            int result = pstmt.executeUpdate();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // 게시글 수정 메서드
    public static boolean updatePost(Connection conn, int postId, String title, String content) {
        String sql = "UPDATE POSTS SET TITLE = ?, CONTENT = ?, UPDATED_AT = NOW() WHERE POST_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, title);
            pstmt.setString(2, content);
            pstmt.setInt(3, postId);
            int result = pstmt.executeUpdate();
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
