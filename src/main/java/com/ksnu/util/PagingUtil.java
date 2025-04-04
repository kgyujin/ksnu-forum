package com.ksnu.util;

import jakarta.servlet.http.HttpServletRequest;

public class PagingUtil {

    public static int getPageNum(HttpServletRequest request) {
        int pageNum = 1;
        String pageParam = request.getParameter("page");
        try {
            if (pageParam != null) {
                pageNum = Integer.parseInt(pageParam);
                if (pageNum < 1) pageNum = 1;
            }
        } catch (NumberFormatException e) {
            pageNum = 1;
        }
        return pageNum;
    }

    public static int calculateOffset(int pageNum, int itemsPerPage) {
        return (pageNum - 1) * itemsPerPage;
    }

    public static int calculateTotalPages(int totalItems, int itemsPerPage) {
        return (int) Math.ceil((double) totalItems / itemsPerPage);
    }

    public static String generatePagination(int currentPage, int totalPages, String url, String query) {
        int groupSize = 10;
        int startPage = ((currentPage - 1) / groupSize) * groupSize + 1;
        int endPage = Math.min(startPage + groupSize - 1, totalPages);

        StringBuilder pagination = new StringBuilder();
        if (startPage > 1) {
            pagination.append("<a href='").append(url).append("?").append(query).append("&page=1'>&lt;&lt;</a>");
            pagination.append("<a href='").append(url).append("?").append(query).append("&page=").append(startPage - 1).append("'>&lt;</a>");
        }

        for (int i = startPage; i <= endPage; i++) {
            if (i == currentPage) {
                pagination.append("<span class='active'>").append(i).append("</span>");
            } else {
                pagination.append("<a href='").append(url).append("?").append(query).append("&page=").append(i).append("'>").append(i).append("</a>");
            }
        }

        if (endPage < totalPages) {
            pagination.append("<a href='").append(url).append("?").append(query).append("&page=").append(endPage + 1).append("'>&gt;</a>");
            pagination.append("<a href='").append(url).append("?").append(query).append("&page=").append(totalPages).append("'>&gt;&gt;</a>");
        }

        return pagination.toString();
    }
}
