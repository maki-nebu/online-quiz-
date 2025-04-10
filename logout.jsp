<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidate the existing session using the implicit session variable
    if (session != null) {
        session.invalidate(); // Clear the session
    }
    // Redirect to the login page after logout
    response.sendRedirect("login.jsp");
%>