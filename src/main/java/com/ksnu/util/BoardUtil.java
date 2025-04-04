package com.ksnu.util;

import jakarta.servlet.http.HttpServletRequest;

public class BoardUtil {
    public static int getBoardId(HttpServletRequest request) {
        String boardIdParam = request.getParameter("boardId");
        int boardId = 0;

        try {
            if (boardIdParam != null && !boardIdParam.isEmpty()) {
                boardId = Integer.parseInt(boardIdParam);
            } else {
                System.out.println("Board ID가 존재하지 않습니다.");
            }
        } catch (NumberFormatException e) {
            System.out.println("잘못된 Board ID 형식: " + boardIdParam);
        }

        return boardId;
    }
}
