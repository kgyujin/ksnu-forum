<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, java.nio.file.*, org.apache.commons.fileupload2.core.*, org.apache.commons.fileupload2.jakarta.servlet6.*, jakarta.servlet.http.*, jakarta.servlet.annotation.*" %>
<%@ include file="/db/dbConnection.jsp" %>

<%
    int postId = 0;
    int boardId = 0;
    String title = "";
    String content = "";
    String[] deleteImages = null;

    String uploadPath = application.getRealPath("/") + "uploads/";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdirs();

    try {
        if (JakartaServletFileUpload.isMultipartContent(request)) {
            DiskFileItemFactory factory = DiskFileItemFactory.builder().get();
            JakartaServletFileUpload upload = new JakartaServletFileUpload(factory);
            List<FileItem> formItems = upload.parseRequest(request);

            for (FileItem item : formItems) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = new String(item.getString().getBytes("ISO-8859-1"), "UTF-8");

                    if ("postId".equals(fieldName)) {
                        postId = Integer.parseInt(fieldValue);
                    } else if ("boardId".equals(fieldName)) {
                        boardId = Integer.parseInt(fieldValue);
                    } else if ("title".equals(fieldName)) {
                        title = fieldValue;
                    } else if ("content".equals(fieldName)) {
                        content = fieldValue;
                    } else if ("deleteImage".equals(fieldName)) {
                        deleteImages = request.getParameterValues("deleteImage");
                    }
                }
            }

            // 이미지 삭제 처리
            if (deleteImages != null) {
                String deleteSql = "DELETE FROM post_images WHERE IMAGE_ID = ?";
                PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
                for (String imageId : deleteImages) {
                    deleteStmt.setInt(1, Integer.parseInt(imageId));
                    deleteStmt.executeUpdate();
                }
                deleteStmt.close();
            }

            // 게시글 수정
            String updateSql = "UPDATE POSTS SET TITLE = ?, CONTENT = ?, UPDATED_AT = NOW() WHERE POST_ID = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setString(1, title);
            updateStmt.setString(2, content);
            updateStmt.setInt(3, postId);
            updateStmt.executeUpdate();
            updateStmt.close();

            // 이미지 추가 처리
            for (FileItem item : formItems) {
                if (!item.isFormField()) {
                    String fileName = new File(item.getName()).getName();
                    if (!fileName.isEmpty()) {
                        String filePath = uploadPath + fileName;
                        item.write(Path.of(filePath));

                        // DB에 이미지 정보 저장
                        String sql = "INSERT INTO post_images (POST_ID, IMAGE_PATH, BOARD_ID) VALUES (?, ?, ?)";
                        PreparedStatement stmt = conn.prepareStatement(sql);
                        stmt.setInt(1, postId);
                        stmt.setString(2, "uploads/" + fileName);
                        stmt.setInt(3, boardId);
                        stmt.executeUpdate();
                        stmt.close();
                    }
                }
            }

            response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);
        }
    } catch (Exception e) {
        out.println("수정 실패: " + e.getMessage());
    }
%>
