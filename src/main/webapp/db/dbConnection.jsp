<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.Properties" %>

<%
    Connection conn = null;
    String jdbcUrl = null;
    String dbId = null;
    String dbPass = null;
    String dbDriver = null;

    try {
        // config.properties 파일 경로
        String configPath = application.getRealPath("/WEB-INF/config.properties");
        Properties props = new Properties();

        // 프로퍼티 파일 로드
        FileInputStream fis = new FileInputStream(configPath);
        props.load(fis);

        // DB 연결 정보 가져오기
        jdbcUrl = props.getProperty("db.url");
        dbId = props.getProperty("db.user");
        dbPass = props.getProperty("db.password");
        dbDriver = props.getProperty("db.driver");

        Class.forName(dbDriver);
        conn = DriverManager.getConnection(jdbcUrl, dbId, dbPass);
        // out.println("DB 연결 성공");
    } catch (Exception e) {
        // out.println("DB 연결 실패: " + e.getMessage());
        e.printStackTrace();
    }
%>