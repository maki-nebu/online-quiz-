<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>

<%
    String message = "";
    String studentId = request.getParameter("student_id");
    String username = "", college = "", department = "", yearId = "", semester = "";

    // Fetch existing student details
    if (studentId != null) {
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
            String selectQuery = "SELECT username, college, department, year_id, semester FROM student_table WHERE student_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(selectQuery)) {
                pstmt.setInt(1, Integer.parseInt(studentId));
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    username = rs.getString("username");
                    college = rs.getString("college");
                    department = rs.getString("department");
                    yearId = rs.getString("year_id");
                    semester = rs.getString("semester");
                } else {
                    message = "No student found with the provided ID.";
                }
            }
        } catch (SQLException e) {
            message = "Error fetching student details: " + e.getMessage();
            e.printStackTrace();
        }
    }

    // Handle form submission for editing a student
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newUsername = request.getParameter("username");
        String newPassword = request.getParameter("password");
        String newCollege = request.getParameter("college");
        String newDepartment = request.getParameter("department");
        String newYearId = request.getParameter("year");
        String newSemester = request.getParameter("semester");

        // Validate fields
        if (newUsername.isEmpty() || newPassword.isEmpty() || newCollege.isEmpty() || newDepartment.isEmpty()) {
            message = "All fields are required.";
        } else {
            // Update student details in the database
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                String updateQuery = "UPDATE student_table SET username = ?, password = ?, college = ?, department = ?, year_id = ?, semester = ? WHERE student_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {
                    pstmt.setString(1, newUsername);
                    pstmt.setString(2, newPassword); // Hash the password in a production environment
                    pstmt.setString(3, newCollege);
                    pstmt.setString(4, newDepartment);
                    pstmt.setString(5, newYearId);
                    pstmt.setString(6, newSemester);
                    pstmt.setInt(7, Integer.parseInt(studentId));

                    int rowsUpdated = pstmt.executeUpdate();
                    if (rowsUpdated > 0) {
                        // Redirect after successful update with success message
                        response.sendRedirect("edit-student.jsp?student_id=" + studentId + "&message=Student details updated successfully.");
                        return; // Prevent further processing
                    } else {
                        message = "Failed to update student details. No rows affected.";
                    }
                }
            } catch (SQLException e) {
                message = "Error updating student details: " + e.getMessage();
                e.printStackTrace();
            }
        }
    }

    // Retrieve success message from the query parameter
    String successMessage = request.getParameter("message");
    if (successMessage != null) {
        message = successMessage; // Use the success message from the parameter
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Student</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4; }
        header { background-color: #333; color: white; padding: 1em; text-align: center; }
        .main-content { margin: 20px; padding: 20px; background-color: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); max-width: 400px; margin: auto; }
        h1 { text-align: center; color: #333; }
        form { display: flex; flex-direction: column; }
        label { margin-bottom: 5px; }
        input[type="text"], input[type="password"] { padding: 10px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; font-size: 16px; }
        button { background-color: #333; color: white; padding: 10px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; }
        button:hover { background-color: #0056b3; }
        .message { color: green; text-align: center; }
        .error { color: red; text-align: center; }
    </style>
</head>
<body>
    <header>
        <h1>Edit Student</h1>
    </header>
    <div class="main-content">
        <%
            if (!message.isEmpty()) {
                out.println("<p class='message'>" + message + "</p>");
            }
        %>
        <form action="<%= request.getRequestURI() %>" method="post">
            <input type="hidden" name="student_id" value="<%= studentId %>">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" value="<%= username %>" required>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
            <label for="college">College:</label>
            <input type="text" id="college" name="college" value="<%= college %>" required>
            <label for="department">Department:</label>
            <input type="text" id="department" name="department" value="<%= department %>" required>
            <label for="year">Year:</label>
            <input type="text" id="year" name="year" value="<%= yearId %>" required>
            <label for="semester">Semester:</label>
            <input type="text" id="semester" name="semester" value="<%= semester %>" required>
            <button type="submit">Save Changes</button>
        </form>
        <form action="manage_students.jsp" method="get">
            <button type="submit" class="back-button">Back</button>
        </form>
    </div>
</body>
</html>