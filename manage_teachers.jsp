<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Teachers</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        header {
            background-color: #333;
            color: white;
            padding: 1em;
            text-align: center;
        }
        .sidebar {
            height: 100vh;
            width: 200px;
            background-color: #333;
            position: fixed;
            top: 0;
            left: 0;
            padding-top: 20px;
        }
        .sidebar a {
            padding: 15px;
            text-decoration: none;
            color: white;
            display: block;
            text-align: center;
        }
        .sidebar a:hover {
            background-color: #ddd;
            color: black;
        }
        .main-content {
            margin-left: 220px;
            padding: 20px;
        }
        .success-message, .error-message {
            color: green;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .error-message {
            color: red;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table, th, td {
            border: 1px solid #ddd;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .btn {
            background-color: #007BFF;
            color: white;
            padding: 5px 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn:hover {
            background-color: #0056b3;
        }
        .action-links {
            display: flex;
            gap: 5px; /* Space between buttons */
        }
        .action-links a, .action-links button {
            background-color: #28a745; /* Green for Edit */
            color: white;
            padding: 5px 10px;
            text-decoration: none;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .action-links button.delete {
            background-color: #dc3545; /* Red for Delete */
        }
        .action-links a:hover, .action-links button:hover {
            opacity: 0.8;
        }
        .password-toggle {
            display: flex;
            align-items: center;
        }
        .password-toggle button {
            background: none;
            border: none; /* Remove border */
            cursor: pointer;
            outline: none;
        }
    </style>
    <script>
        function confirmDelete() {
            return confirm("Are you sure you want to delete this teacher?");
        }

        function validatePassword() {
            const passwordInput = document.getElementById("password");
            const errorMessage = document.getElementById("passwordError");
            const password = passwordInput.value;

            const regex = /^(?=.*[A-Z])(?=.*\d).{8,}$/; // At least 8 chars, 1 uppercase, 1 number

            if (password.length < 8 || !regex.test(password)) {
                errorMessage.textContent = "Password must be at least 8 characters, include an uppercase letter and a number.";
                return false;
            } else {
                errorMessage.textContent = "";
                return true;
            }
        }
    </script>
</head>
<body>
    <header>
        <h1>Manage Teachers</h1>
    </header>
    <div class="sidebar">
        <h2 style="color: white">Admin Panel</h2>
        <a href="#">Dashboard</a>
        <a href="manage_students.jsp">Manage Students</a>
        <a href="manage_teachers.jsp">Manage Teachers</a>
        <a href="course.jsp">Manage Courses</a>
        <a href="adminquiz.jsp">Manage Quiz</a>
        <a href="admin_view_scores.jsp">Manage Results</a>
        <a href="admin_profile.jsp">Profile</a>
    </div>
    <div class="main-content">

        <!-- Handle Delete Action -->
        <% 
            if ("delete".equals(request.getParameter("action"))) {
                String teacherId = request.getParameter("id");
                try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                    String sql = "DELETE FROM teacher_table WHERE teacher_id = ?";
                    try (PreparedStatement stmt = con.prepareStatement(sql)) {
                        stmt.setInt(1, Integer.parseInt(teacherId));
                        int rows = stmt.executeUpdate();
                        if (rows > 0) {
                            out.println("<div class='success-message'>Teacher deleted successfully</div>");
                        } else {
                            out.println("<div class='error-message'>Failed to delete teacher</div>");
                        }
                    }
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                }
            }

            // Handle Add Teacher Action
            if ("create".equals(request.getParameter("action"))) {
                String username = request.getParameter("username");
                String password = request.getParameter("password");
                String college = request.getParameter("college");
                String department = request.getParameter("department");
                int yearId = Integer.parseInt(request.getParameter("year_id"));
                String semester = request.getParameter("semester");
                String courseName = request.getParameter("course_name"); // Ensure this matches the input name
                
                // Password Encryption
                String hashedPassword = null;
                try {
                    MessageDigest md = MessageDigest.getInstance("SHA-256");
                    byte[] hashedBytes = md.digest(password.getBytes("UTF-8"));
                    StringBuilder sb = new StringBuilder();
                    for (byte b : hashedBytes) {
                        sb.append(String.format("%02x", b));
                    }
                    hashedPassword = sb.toString();
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error hashing password: " + e.getMessage() + "</div>");
                }

                try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                    String sql = "INSERT INTO teacher_table (username, password, college, department, year_id, semester, course_name) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement stmt = con.prepareStatement(sql)) {
                        stmt.setString(1, username);
                        stmt.setString(2, hashedPassword); // Use hashed password
                        stmt.setString(3, college);
                        stmt.setString(4, department);
                        stmt.setInt(5, yearId);
                        stmt.setString(6, semester);
                        stmt.setString(7, courseName); // Ensure this is used in the statement
                        int rows = stmt.executeUpdate();
                        if (rows > 0) {
                            out.println("<div class='success-message'>Teacher added successfully</div>");
                        } else {
                            out.println("<div class='error-message'>Failed to add teacher</div>");
                        }
                    }
                } catch (Exception e) {
                    out.println("<div class='error-message'>Error: " + e.getMessage() + "</div>");
                }
            }
        %>

        <!-- Add New Teacher Form -->
        <form action="manage_teachers.jsp" method="post" onsubmit="return validatePassword();">
            <input type="hidden" name="action" value="create">
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" required>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
            <div id="passwordError" class="error-message"></div> <!-- Error message for password validation -->
            <label for="college">College:</label>
            <input type="text" id="college" name="college" required>
            <label for="department">Department:</label>
            <input type="text" id="department" name="department" required>
            <label for="year_id">Year ID:</label>
            <input type="text" id="year_id" name="year_id" pattern="[1-5]" title="Only numbers 1-5 are allowed" required>
            <label for="semester">Semester:</label>
            <input type="text" id="semester" name="semester" required>
            <label for="course">Course Name:</label>
            <input type="text" id="course" name="course_name" required>
            <button type="submit" class="btn">Add Teacher</button>
        </form>

        <h1>Teacher List</h1>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Username</th>
                    <th>College</th>
                    <th>Department</th>
                    <th>Year ID</th>
                    <th>Semester</th>
                    <th>Course Name</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    Connection con = null;
                    Statement stmt = null;
                    ResultSet rs = null;

                    try {
                        con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                        stmt = con.createStatement();
                        rs = stmt.executeQuery("SELECT * FROM teacher_table");

                        while (rs.next()) {
                %>
                    <tr>
                        <td><%= rs.getInt("teacher_id") %></td>
                        <td><%= rs.getString("username") %></td>
                        <td><%= rs.getString("college") %></td>
                        <td><%= rs.getString("department") %></td>
                        <td><%= rs.getInt("year_id") %></td>
                        <td><%= rs.getString("semester") %></td>
                        <td><%= rs.getString("course_name") %></td>
                        <td class="action-links">
                            <a href="edit_teacher.jsp?id=<%= rs.getInt("teacher_id") %>" class="btn">Edit</a>
                            <form action="manage_teachers.jsp" method="post" style="display: inline;" onsubmit="return confirmDelete();">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= rs.getInt("teacher_id") %>">
                                <button type="submit" class="btn delete">Delete</button>
                            </form>
                        </td>
                    </tr>
                <% 
                        }
                    } catch (SQLException e) {
                        out.println("<div class='error-message'>Database error: " + e.getMessage() + "</div>");
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                        if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
                        if (con != null) try { con.close(); } catch (SQLException ignored) {}
                    }
                %>
            </tbody>
        </table>
    </div>
</body>
</html>