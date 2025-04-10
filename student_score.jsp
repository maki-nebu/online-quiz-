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
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 800px;
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
        .alert {
            color: #d9534f;
            text-align: center;
            margin-bottom: 20px;
            font-weight: bold;
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
            background-color: #007bff;
            color: #fff;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .footer {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            color: #777;
        }
        a {
            color: #007bff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="container">
<h2>My Results</h2>
<%
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
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
        String query = "SELECT course_id, score, course_name FROM results WHERE student_id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, studentId);
        rs = pstmt.executeQuery();

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
    <div class="footer">
        <p>Need help? <a href="studentDashboard.jsp">Go back to Student Dashboard</a></p>
    </div>
</div>
</body>
</html>
