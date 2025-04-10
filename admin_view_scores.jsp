<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - View All Student Results</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
        }
        .container {
            max-width: 1000px;
            margin: 50px auto;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }
        h2 {
            color: #333;
            text-align: center;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }
        th {
            background-color: #333;
            color: #fff;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .delete-btn {
            padding: 6px 10px;
            color: #fff;
            background-color: #dc3545;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .delete-btn:hover {
            background-color: #c82333;
        }
    </style>
</head>
<body>
<div class="container">
<h2>All Student Results</h2>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Connect to the database
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

        // Check if a delete request was made
        String deleteStudentId = request.getParameter("delete_student_id");
        String deleteCourseId = request.getParameter("delete_course_id");
        if (deleteStudentId != null && deleteCourseId != null) {
            String deleteQuery = "DELETE FROM results WHERE student_id = ? AND course_id = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteQuery);
            deleteStmt.setInt(1, Integer.parseInt(deleteStudentId));
            deleteStmt.setInt(2, Integer.parseInt(deleteCourseId));
            deleteStmt.executeUpdate();
            deleteStmt.close();
        }

        // Query to select all results
        String query = "SELECT student_id, course_id, score, course_name, username FROM results";
        pstmt = conn.prepareStatement(query);
        rs = pstmt.executeQuery();

        // Display results in a table
        out.println("<table>");
        out.println("<tr><th>Student ID</th><th>Course ID</th><th>Score</th><th>Course Name</th><th>Username</th><th>Actions</th></tr>");
        
        while (rs.next()) {
            int studentId = rs.getInt("student_id");
            int courseId = rs.getInt("course_id");
            out.println("<tr>");
            out.println("<td>" + studentId + "</td>");
            out.println("<td>" + courseId + "</td>");
            out.println("<td>" + rs.getInt("score") + "</td>");
            out.println("<td>" + rs.getString("course_name") + "</td>");
            out.println("<td>" + rs.getString("username") + "</td>");
            out.println("<td>");
            out.println("<form method='post' style='display:inline;'>");
            out.println("<input type='hidden' name='delete_student_id' value='" + studentId + "'>");
            out.println("<input type='hidden' name='delete_course_id' value='" + courseId + "'>");
            out.println("<button type='submit' class='delete-btn'>Delete</button>");
            out.println("</form>");
            out.println("</td>");
            out.println("</tr>");
        }
        out.println("</table>");
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h2 class='alert'>Database error: " + e.getMessage() + "</h2>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>
</div>
</body>
</html>
