package com.ksnu.util;

import jakarta.servlet.http.HttpSession;

public class SessionCheck {

    public static boolean isLoggedIn(HttpSession session) {
        if (session == null) return false;
        String userId = (String) session.getAttribute("userId");
        return userId != null;
    }

    public static String getUserId(HttpSession session) {
        if (isLoggedIn(session)) {
            return (String) session.getAttribute("userId");
        }
        return null;
    }

    public static void logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }
}