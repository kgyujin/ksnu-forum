package com.ksnu.util;

import jakarta.servlet.http.HttpServletRequest;

public class PagingUtil {

    public static int getPageNum(HttpServletRequest request) {
    	String pageNumStr = request.getParameter("page");
        int pageNum = 1;
        
        if (pageNumStr != null && !pageNumStr.isEmpty()) {
            try {
                pageNum = Integer.parseInt(pageNumStr);
                if (pageNum < 1) pageNum = 1;
            } catch (NumberFormatException e) {
                pageNum = 1;
            }
        }
        
        return pageNum;
    }
    
    public static int calculateOffset(int pageNum, int itemsPerPage) {
        return (pageNum - 1) * itemsPerPage;
    }
    
    public static int calculateTotalPages(int totalItems, int itemsPerPage) {
        return (int) Math.ceil((double) totalItems / itemsPerPage);
    }
    
    public static String generatePagination(int currentPage, int totalPages, String url, String queryParams) {
        StringBuilder pagination = new StringBuilder();
        
        // 페이지 범위 계산 (현재 페이지 주변 4페이지씩 표시)
        int startPage = Math.max(1, currentPage - 2);
        int endPage = Math.min(totalPages, currentPage + 2);
        
        // 이전 페이지 버튼
        if (currentPage > 1) {
            pagination.append("<a href=\"").append(url).append("?").append(queryParams).append("&page=1\"><<</a> ");
            pagination.append("<a href=\"").append(url).append("?").append(queryParams).append("&page=").append(currentPage - 1).append("\"><</a> ");
        }
        
        // 페이지 번호
        for (int i = startPage; i <= endPage; i++) {
            if (i == currentPage) {
                // 현재 페이지는 strong 태그로 표시
                pagination.append("<strong>").append(i).append("</strong> ");
            } else {
                pagination.append("<a href=\"").append(url).append("?").append(queryParams).append("&page=").append(i).append("\">").append(i).append("</a> ");
            }
        }
        
        // 다음 페이지 버튼
        if (currentPage < totalPages) {
            pagination.append("<a href=\"").append(url).append("?").append(queryParams).append("&page=").append(currentPage + 1).append("\">></a> ");
            pagination.append("<a href=\"").append(url).append("?").append(queryParams).append("&page=").append(totalPages).append("\">>></a>");
        }
        
        return pagination.toString();
    }
}
