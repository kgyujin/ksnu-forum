<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.io.*, java.nio.file.*, org.apache.commons.fileupload2.core.*, org.apache.commons.fileupload2.jakarta.servlet6.*, jakarta.servlet.http.*, jakarta.servlet.annotation.*" %>
<%@ page import="com.ksnu.util.BoardUtil" %>
<%@ include file="/db/dbConnection.jsp" %>

<%
String uploadPath = application.getRealPath("/") + "uploads/";
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) uploadDir.mkdirs();

int boardId = 0;
int postId = 0;
String title = "";
String content = "";
int userId = 0;

try
{
    // 세션에서 userId 가져오기
    Object userIdObj = session.getAttribute("userId");
    if (userIdObj != null)
    {
        userId = Integer.parseInt(userIdObj.toString());
    }
    else
    {
        out.println("로그인 정보가 없습니다.");
        return;
    }

    if (JakartaServletFileUpload.isMultipartContent(request))
    {
        DiskFileItemFactory factory = DiskFileItemFactory.builder().get();
        JakartaServletFileUpload upload = new JakartaServletFileUpload(factory);
        List<FileItem> formItems = upload.parseRequest(request);

        for (FileItem item : formItems)
        {
            if (item.isFormField())
            {
                // form 필드 데이터 처리
                String fieldName = item.getFieldName();
                String fieldValue = new String(item.getString().getBytes("ISO-8859-1"), "UTF-8");

                if ("boardId".equals(fieldName))
                {
                    try
                    {
                        boardId = Integer.parseInt(fieldValue);
                    }
                    catch (NumberFormatException e)
                    {
                        out.println("잘못된 boardId 형식입니다: " + fieldValue);
                        return;
                    }
                }
                else if ("title".equals(fieldName))
                {
                    title = fieldValue;
                }
                else if ("content".equals(fieldName))
                {
                    content = fieldValue;
                }
            }
        }

        if (boardId == 0)
        {
            out.println("유효하지 않은 boardId입니다.");
            return;
        }

        // 1. 게시글을 먼저 추가하고, 생성된 POST_ID를 가져옴
        String postSql = "INSERT INTO posts (BOARD_ID, USER_ID, TITLE, CONTENT) VALUES (?, ?, ?, ?)";
        PreparedStatement postStmt = conn.prepareStatement(postSql, Statement.RETURN_GENERATED_KEYS);
        postStmt.setInt(1, boardId);
        postStmt.setInt(2, userId);
        postStmt.setString(3, title);
        postStmt.setString(4, content);
        postStmt.executeUpdate();

        // 생성된 게시글 ID 가져오기
        ResultSet rs = postStmt.getGeneratedKeys();
        if (rs.next())
        {
            postId = rs.getInt(1);
        }
        rs.close();
        postStmt.close();

        // 2. 파일 업로드 처리
        for (FileItem item : formItems)
        {
            if (!item.isFormField())
            {
                String rawName = item.getName();
                if (rawName == null || rawName.trim().isEmpty() || item.getSize() == 0)
                {
                    continue; // 파일명이 없거나 비어있는 파일은 건너뜀
                }

                String fileName = new File(rawName).getName(); // 안전하게 추출
                String filePath = uploadPath + fileName;

                try
                {
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
                catch (Exception e)
                {
                    out.println("파일 저장 중 오류: " + e.getClass().getName() + " - " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
	}
	response.sendRedirect("/board/boardView.jsp?boardId=" + boardId + "&postId=" + postId);
}
catch (Exception ex)
{
    out.println("파일 업로드 실패: " + ex.getClass().getName() + " - " + ex.getMessage());
    ex.printStackTrace();
}
%>
