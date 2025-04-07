package com.ksnu.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.util.List;

import org.apache.commons.fileupload2.core.DiskFileItemFactory;
import org.apache.commons.fileupload2.core.FileItem;
import org.apache.commons.fileupload2.jakarta.servlet6.JakartaServletFileUpload;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "UploadServlet", urlPatterns = {"/fileUpload.do"})
public class FileUploadServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (JakartaServletFileUpload.isMultipartContent(request)) {
            DiskFileItemFactory factory = DiskFileItemFactory.builder().get();
            JakartaServletFileUpload upload = new JakartaServletFileUpload(factory);
            upload.setFileSizeMax(1024 * 1024); // 개별 파일 최대 크기: 1MB
            upload.setSizeMax(10 * 1024 * 1024); // 전체 요청 최대 크기: 10MB

            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploadedFiles";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            try {
                List<FileItem> formItems = upload.parseRequest(request);
                if (formItems != null && !formItems.isEmpty()) {
                    for (FileItem item : formItems) {
                        if (!item.isFormField()) {
                            String fileName = new File(item.getName()).getName();
                            item.write(Path.of(uploadPath, fileName));
                            response.getWriter().println(String.format(
                                "필드 이름: %s, 파일 이름: %s, 파일 크기: %s 바이트<br>",
                                item.getFieldName(),
                                item.getName(),
                                item.getSize()
                            ));
                        }
                    }
                }
            } catch (Exception e) {
                response.getWriter().println("파일 업로드 중 오류 발생: " + e.getMessage());
            }
        }
    }
}
