<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    String message = null;
    String studentId = request.getParameter("id");
    String username = "";
    String college = "";
    String department = "";
    String year = "";
    String semester = "";

    // SQL Query to fetch existing student details
    String selectQuery = "SELECT username, college, department, year_id AS year, semester FROM student_table WHERE student_id = ?";

    // Fetch existing student details based on student ID
    if (studentId != null) {
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
            try (PreparedStatement pstmt = conn.prepareStatement(selectQuery)) {
                pstmt.setString(1, studentId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    username = rs.getString("username");
                    college = rs.getString("college");
                    department = rs.getString("department");
                    year = rs.getString("year");
                    semester = rs.getString("semester");
                } else {
                    message = "No student found with the provided ID.";
                }
            }
        } catch (SQLException e) {
            message = "Error fetching student details: " + e.getMessage();
        }
    } else {
        message = "Student ID is missing.";
    }

    // Handle the update operation
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newUsername = request.getParameter("username");
        String newPassword = request.getParameter("password");
        String newCollege = request.getParameter("college");
        String newDepartment = request.getParameter("department");
        String newYear = request.getParameter("year");
        String newSemester = request.getParameter("semester");

        // Update student details in the database
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
            String updateQuery = "UPDATE student_table SET username=?, password=?, college=?, department=?, year_id=?, semester=? WHERE student_id=?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {
                pstmt.setString(1, newUsername);
                pstmt.setString(2, newPassword); // Ensure to hash the password in a real application
                pstmt.setString(3, newCollege);
                pstmt.setString(4, newDepartment);
                pstmt.setString(5, newYear);
                pstmt.setString(6, newSemester);
                pstmt.setString(7, studentId);
                
                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                    message = "Student details updated successfully!";
                    
                    // Re-fetch the details to show updated values
                    try (PreparedStatement pstmtSelect = conn.prepareStatement(selectQuery)) {
                        pstmtSelect.setString(1, studentId);
                        ResultSet rs = pstmtSelect.executeQuery();
                        if (rs.next()) {
                            username = rs.getString("username");
                            college = rs.getString("college");
                            department = rs.getString("department");
                            year = rs.getString("year");
                            semester = rs.getString("semester");
                        }
                    }
                } else {
                    message = "Failed to update student details.";
                }
            }
        } catch (SQLException e) {
            message = "Error updating student details: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Student</title>
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
        .main-content {
            margin: 20px;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            max-width: 400px;
            margin: auto; /* Center the main content */
        }
        h1 {
            text-align: center;
            color: #333;
        }
        form {
            display: flex;
            flex-direction: column;
        }
        label {
            margin-bottom: 5px;
        }
        input[type="text"],
        input[type="password"],
        select {
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
        }
        button {
            background-color: #333;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 10px; /* Add some space above the button */
        }
        button:hover {
            background-color: #0056b3;
        }
        .message {
            color: green;
            text-align: center;
        }
        .error {
            color: red;
            text-align: center;
        }
        .back-button {
            background-color: #777;
            margin-top: 20px;
        }
        .back-button:hover {
            background-color: #555;
        }
        .password-container {
            position: relative;
            margin-bottom: 15px; /* Space below the password field */
        }
        .password-container input[type="password"] {
            padding-right: 40px; /* Space for the eye icon */
        }
        .toggle-password {
            cursor: pointer;
            position: absolute;
            right: 10px; /* Position it inside the input */
            top: 50%;
            transform: translateY(-50%); /* Center it vertically */
            z-index: 1; /* Ensure it appears above the input */
        }
    </style>
    <script>
        function validatePassword() {
            const passwordInput = document.getElementById("password");
            const password = passwordInput.value;
            const message = document.getElementById("passwordMessage");

            // Regular expression for password validation
            const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;

            if (!regex.test(password)) {
                message.textContent = "Password must be at least 8 characters long, include at least one uppercase letter, one lowercase letter, and one number.";
                return false;
            } else {
                message.textContent = "";
                return true;
            }
        }

        function togglePassword() {
            const passwordInput = document.getElementById("password");
            const toggleButton = document.getElementById("togglePassword");
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            toggleButton.textContent = type === 'password' ? '👁️' : '🙈'; // Change icon based on visibility
        }
    </script>
</head>
<body>
    <header>
        <h1>Edit Student</h1>
    </header>
    <div class="main-content">
        <%
            if (message != null) {
                out.println("<p class='message'>" + message + "</p>");
            }
        %>
        <form action="<%= request.getRequestURI() %>" method="post" onsubmit="return validatePassword();">
            <input type="hidden" name="id" value="<%= studentId %>">
            
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" value="<%= username %>" required>
            
            <label for="password">Password:</label>
            <div class="password-container">
                <input type="password" id="password" name="password" required>
                <span id="togglePassword" class="toggle-password" onclick="togglePassword()">👁️</span> <!-- Eye icon for toggling -->
            </div>
            <div id="passwordMessage" class="error"></div> <!-- Password validation message -->
            
            <label for="college">College:</label>
            <input type="text" id="college" name="college" value="<%= college %>" required>
            
            <label for="department">Department:</label>
            <input type="text" id="department" name="department" value="<%= department %>" required>
            
            <label for="year">Year:</label>
            <select id="year" name="year" required>
                <option value="">Select Year</option>
                <option value="1" <%= "1".equals(year) ? "selected" : "" %>>1</option>
                <option value="2" <%= "2".equals(year) ? "selected" : "" %>>2</option>
                <option value="3" <%= "3".equals(year) ? "selected" : "" %>>3</option>
                <option value="4" <%= "4".equals(year) ? "selected" : "" %>>4</option>
                <option value="5" <%= "5".equals(year) ? "selected" : "" %>>5</option>
            </select>
            
            <label for="semester">Semester:</label>
            <select id="semester" name="semester" required>
                <option value="">Select Semester</option>
                <option value="1" <%= "1".equals(semester) ? "selected" : "" %>>1</option>
                <option value="2" <%= "2".equals(semester) ? "selected" : "" %>>2</option>
            </select>
            
            <button type="submit">Save Changes</button>
        </form>
        <form action="manage_students.jsp" method="get"> <!-- Redirect to Student List page -->
            <button type="submit" class="back-button">Back</button>
        </form>
    </div>
</body>
</html>