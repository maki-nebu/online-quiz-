<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student - View My Results</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        h2 {
            color: #333;
            text-align: center;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        th, td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
        }

        th {
            background-color: #4CAF50;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        tr:hover {
            background-color: #ddd;
        }

        .alert {
            color: red;
            text-align: center;
            margin-top: 20px;
        }

        .success {
            color: green;
            text-align: center;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="container">
<h2>My Results</h2>
<%
    // Use the implicit session object directly
    HttpSession session = request.getSession(); // Ensure to get the session object
    String loggedStudentId = (String) session.getAttribute("student_id");

    if (loggedStudentId == null) {
        out.println("<h2 class='alert'>You are not logged in. Please log in to view your results.</h2>");
        return;
    }

    int studentId = Integer.parseInt(loggedStudentId);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Connect to the database
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

        // Query to select results for the logged-in student
        String query = "SELECT course_id, score, course_name FROM results WHERE student_id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, studentId);
        rs = pstmt.executeQuery();

        // Display results in a table
        out.println("<table>");
        out.println("<tr><th>Course ID</th><th>Score</th><th>Course Name</th></tr>");
        
        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("course_id") + "</td>");
            out.println("<td>" + rs.getInt("score") + "</td>");
            out.println("<td>" + rs.getString("course_name") + "</td>");
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