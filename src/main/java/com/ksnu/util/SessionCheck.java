package com.ksnu.util;

import jakarta.servlet.http.HttpSession;

public class SessionCheck {

    public static boolean isLoggedIn(HttpSession session) {
        if (session == null) return false;

        // 세션에서 userId를 Integer로 가져옴
        Integer userId = (Integer) session.getAttribute("userId");
        return userId != null && userId > 0;
    }

    public static int getUserId(HttpSession session) {
        if (isLoggedIn(session)) {
            Integer userId = (Integer) session.getAttribute("userId");
            return (userId != null) ? userId : -1;
        }
        return -1;
    }

    public static void logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }
}
