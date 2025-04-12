<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/header.jsp" %>
<%@ include file="/db/dbConnection.jsp" %>
<%@ page import="com.ksnu.util.PagingUtil" %>
<%@ page import="com.ksnu.util.BoardUtil" %>

<!DOCTYPE html>
<html>
<head>
    <title>검색 결과</title>
    <meta charset="UTF-8">
    <style>
        .board-container {
            width: 80%;
            margin: 20px auto;
        }
        .board-title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .board-table {
            width: 100%;
            border-collapse: collapse;
        }
        .board-table th, .board-table td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            text-align: center;
        }
        .board-table th {
            background-color: #f2f2f2;
        }
        .board-table td.title {
            text-align: left;
        }
        .board-table tr:hover {
            background-color: #f5f5f5;
        }
        .board-table td.title a {
		    text-decoration: none;
		    color: #333;
		    transition: color 0.3s ease;
		}
		
		.board-table td.title a:hover {
		    color: #007bff;
		}
        .write-btn {
            margin: 20px 0;
            text-align: right;
        }
        .write-btn a {
            padding: 8px 15px;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        /* 페이지 네비게이션 스타일 */
        .pagination {
            margin: 20px auto;
            text-align: center;
        }
        .pagination a, .pagination span {
            margin: 0 3px;
            padding: 5px 10px;
            text-decoration: none;
            color: black;
            border: 1px solid #ddd;
            border-radius: 5px;
            display: inline-block;
        }
        .pagination a:hover {
            background-color: #f2f2f2;
        }
        .pagination .active {
            font-weight: bold;
            background-color: #ddd;
        }
    </style>
</head>
<body>

<div class="board-container">
    <div class="board-title">검색 결과</div>
    
    <table class="board-table">
        <thead>
            <tr>
                <th width="10%">게시판</th>
                <th width="55%">제목</th>
                <th width="20%">내용</th>
                <th width="15%">작성일</th>
            </tr>
        </thead>
        <tbody>
<%
    String query = request.getParameter("query");

    int itemsPerPage = 10;
    int pageNum = PagingUtil.getPageNum(request);
    int offset = PagingUtil.calculateOffset(pageNum, itemsPerPage);

    int totalPosts = 0;
    int totalPages = 1;

    if (query != null && !query.trim().isEmpty()) {
        PreparedStatement countStmt = null;
        ResultSet countRs = null;
        PreparedStatement searchStmt = null;
        ResultSet searchRs = null;

        try {
            // 게시글 수 조회
            String countSql = "SELECT COUNT(*) AS total FROM POSTS WHERE TITLE LIKE ?";
            countStmt = conn.prepareStatement(countSql);
            countStmt.setString(1, "%" + query + "%");
            countRs = countStmt.executeQuery();

            if (countRs.next()) {
                totalPosts = countRs.getInt("total");
                totalPages = PagingUtil.calculateTotalPages(totalPosts, itemsPerPage);
            }

            // 게시글 검색 쿼리 수정: BOARD_ID 추가
            String searchSql = "SELECT b.BOARD_NAME, p.TITLE, p.CONTENT, p.POST_ID, p.BOARD_ID, p.CREATED_AT "
                             + "FROM POSTS p JOIN BOARDS b ON p.BOARD_ID = b.BOARD_ID "
                             + "WHERE p.TITLE LIKE ? ORDER BY p.CREATED_AT DESC LIMIT ? OFFSET ?";
            searchStmt = conn.prepareStatement(searchSql);
            searchStmt.setString(1, "%" + query + "%");
            searchStmt.setInt(2, itemsPerPage);
            searchStmt.setInt(3, offset);
            searchRs = searchStmt.executeQuery();

            boolean hasResults = false;
            
            while (searchRs.next()) {
                hasResults = true;
                String boardName = searchRs.getString("BOARD_NAME");
                String title = searchRs.getString("TITLE");
                String content = searchRs.getString("CONTENT");
                int postId = searchRs.getInt("POST_ID");
                int boardId = searchRs.getInt("BOARD_ID");
                String createdAt = searchRs.getString("CREATED_AT");
                
             	// 내용 요약 (10자 이상이면 자르고 ... 추가)
                String contentSummary = content;
                if (content != null && content.length() > 10) {
                    contentSummary = content.substring(0, 10) + "...";
                }
%>
            <tr>
                <td><%= boardName %></td>
                <td class="title"><a href="/board/boardView.jsp?boardId=<%= boardId %>&postId=<%= postId %>"><%= title %></a></td>
                <td><%= contentSummary %></td>
                <td><%= createdAt %></td>
            </tr>
<%
            }
            
            if (!hasResults) {
%>
            <tr>
                <td colspan="3" style="text-align: center;">검색 결과가 없습니다.</td>
            </tr>
<%
            }
        } catch (Exception e) {
            out.println("<tr><td colspan='3'>검색 오류: " + e.getMessage() + "</td></tr>");
        } finally {
            if (searchRs != null) searchRs.close();
            if (searchStmt != null) searchStmt.close();
            if (countRs != null) countRs.close();
            if (countStmt != null) countStmt.close();
        }
    } else {
%>
        <tr>
            <td colspan="3" style="text-align: center;">검색어를 입력해주세요.</td>
        </tr>
<%
    }
%>
        </tbody>
    </table>

    <!-- 페이지 네비게이션 -->
    <div class="pagination">
<%
    int groupSize = 10;
    int startPage = ((pageNum - 1) / groupSize) * groupSize + 1;
    int endPage = Math.min(startPage + groupSize - 1, totalPages);

    if (startPage > 1) {
%>
        <a href="?query=<%= query %>&page=1"><<</a>
        <a href="?query=<%= query %>&page=<%= startPage - 1 %>"><</a>
<%
    }

    for (int i = startPage; i <= endPage; i++) {
        if (i == pageNum) {
%>
        <span class="active"><%= i %></span>
<%
        } else {
%>
        <a href="?query=<%= query %>&page=<%= i %>"><%= i %></a>
<%
        }
    }

    if (endPage < totalPages) {
%>
        <a href="?query=<%= query %>&page=<%= endPage + 1 %>">></a>
        <a href="?query=<%= query %>&page=<%= totalPages %>">>></a>
<%
    }
%>
    </div>
</div>

</body>
</html>
