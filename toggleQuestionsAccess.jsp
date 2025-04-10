<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>
<%
    // Database connection setup
    String url = "jdbc:mysql://localhost:3305/System_exam";
    String dbUser = "root";
    String dbPassword = "mysql";

    int courseId = Integer.parseInt(request.getParameter("course_id"));
    boolean questionsAccessible = request.getParameter("questions_accessible") != null;

    Connection con = null;
    PreparedStatement stmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(url, dbUser, dbPassword);

        // Update the questions access status in the database
        String updateQuery = "UPDATE courses SET questions_accessible = ? WHERE course_id = ?";
        stmt = con.prepareStatement(updateQuery);
        stmt.setBoolean(1, questionsAccessible);
        stmt.setInt(2, courseId);
        
        stmt.executeUpdate();
        
        response.sendRedirect("control.jsp"); // Redirect back to the admin page
    } catch (SQLException e) {
        e.printStackTrace();
        // Handle error
    } finally {
        if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
        if (con != null) try { con.close(); } catch (SQLException ignore) {}
    }
%>