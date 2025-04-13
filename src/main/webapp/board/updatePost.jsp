<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, java.nio.file.*, org.apache.commons.fileupload2.core.*, org.apache.commons.fileupload2.jakarta.servlet6.*, jakarta.servlet.http.*, jakarta.servlet.annotation.*" %>
<%@ include file="/db/dbConnection.jsp" %>

<%
int postId = 0;
int boardId = 0;
String title = "";
String content = "";

String uploadPath = application.getRealPath("/") + "uploads/";
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) uploadDir.mkdirs();

try {
    if (JakartaServletFileUpload.isMultipartContent(request)) {
        DiskFileItemFactory factory = DiskFileItemFactory.builder().get();
        JakartaServletFileUpload upload = new JakartaServletFileUpload(factory);
        List<FileItem> formItems = upload.parseRequest(request);

        List<String> deleteImageList = new ArrayList<>();

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
                    deleteImageList.add(fieldValue);
                }
            }
        }

        String[] deleteImages = deleteImageList.toArray(new String[0]);

        // ✅ 이미지 삭제 처리
        if (deleteImages != null && deleteImages.length > 0) {
            String selectSql = "SELECT IMAGE_PATH FROM post_images WHERE IMAGE_ID = ?";
            String deleteSql = "DELETE FROM post_images WHERE IMAGE_ID = ?";
            PreparedStatement selectStmt = conn.prepareStatement(selectSql);
            PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);

            for (String imageId : deleteImages) {
                int imgId = Integer.parseInt(imageId);

                // 실제 이미지 경로 가져오기 및 파일 삭제
                selectStmt.setInt(1, imgId);
                ResultSet rs = selectStmt.executeQuery();
                if (rs.next()) {
                    String imagePath = rs.getString("IMAGE_PATH");
                    if (imagePath != null && !imagePath.trim().isEmpty()) {
                        File imageFile = new File(application.getRealPath("/") + imagePath);
                        if (imageFile.exists()) {
                            imageFile.delete();
                        }
                    }
                }
                rs.close();

                // DB에서 이미지 정보 삭제
                deleteStmt.setInt(1, imgId);
                deleteStmt.executeUpdate();
            }
            selectStmt.close();
            deleteStmt.close();
        }

        // ✅ 게시글 수정
        String updateSql = "UPDATE POSTS SET TITLE = ?, CONTENT = ?, UPDATED_AT = NOW() WHERE POST_ID = ?";
        PreparedStatement updateStmt = conn.prepareStatement(updateSql);
        updateStmt.setString(1, title);
        updateStmt.setString(2, content);
        updateStmt.setInt(3, postId);
        updateStmt.executeUpdate();
        updateStmt.close();

        // ✅ 새 이미지 업로드 처리
        for (FileItem item : formItems) {
            if (!item.isFormField()) {
                String fileName = new File(item.getName()).getName();
                if (fileName != null && !fileName.trim().isEmpty() && item.getSize() > 0) {
                    String filePath = uploadPath + fileName;
                    item.write(Path.of(filePath));

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

        // ✅ 완료 후 리다이렉트
        response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);
    }
} catch (Exception e) {
    out.println("수정 실패: " + e.getClass().getName() + " - " + e.getMessage());
    e.printStackTrace();
}
%>
