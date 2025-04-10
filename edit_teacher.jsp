<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<%
    String message = null;
    String teacherId = request.getParameter("id");
    String username = "";
    String college = "";
    String department = "";
    String yearId = "";  
    String semester = "";
    String courseName = "";

    // SQL Query to fetch existing teacher details
    String selectQuery = "SELECT username, college, department, year_id, semester, course_name FROM teacher_table WHERE teacher_id = ?";

    // Fetch existing teacher details based on teacher ID
    if (teacherId != null) {
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
            try (PreparedStatement pstmt = conn.prepareStatement(selectQuery)) {
                pstmt.setString(1, teacherId);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    username = rs.getString("username");
                    college = rs.getString("college");
                    department = rs.getString("department");
                    yearId = rs.getString("year_id");
                    semester = rs.getString("semester");
                    courseName = rs.getString("course_name");
                } else {
                    message = "No teacher found with the provided ID.";
                }
            }
        } catch (Exception e) {
            message = "Error fetching teacher details: " + e.getMessage();
        }
    }

    // Handle form submission for editing a teacher
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newUsername = request.getParameter("username");
        String newPassword = request.getParameter("password");
        String newCollege = request.getParameter("college");
        String newDepartment = request.getParameter("department");
        String newYearId = request.getParameter("year_id");
        String newSemester = request.getParameter("semester");
        String newCourseName = request.getParameter("course_name");

        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
            String updateQuery = "UPDATE teacher_table SET username=?, password=?, college=?, department=?, year_id=?, semester=?, course_name=? WHERE teacher_id=?";
            try (PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {
                pstmt.setString(1, newUsername);
                pstmt.setString(2, newPassword); // Consider hashing the password in real applications
                pstmt.setString(3, newCollege);
                pstmt.setString(4, newDepartment);
                pstmt.setString(5, newYearId);
                pstmt.setString(6, newSemester);
                pstmt.setString(7, newCourseName);
                pstmt.setString(8, teacherId);
                
                int rowsUpdated = pstmt.executeUpdate();
                if (rowsUpdated > 0) {
                    message = "Teacher details updated successfully.";
                    // Re-fetch the details to show updated values
                    try (PreparedStatement pstmtSelect = conn.prepareStatement(selectQuery)) {
                        pstmtSelect.setString(1, teacherId);
                        ResultSet rs = pstmtSelect.executeQuery();
                        if (rs.next()) {
                            username = rs.getString("username");
                            college = rs.getString("college");
                            department = rs.getString("department");
                            yearId = rs.getString("year_id");
                            semester = rs.getString("semester");
                            courseName = rs.getString("course_name");
                        }
                    }
                } else {
                    message = "Failed to update teacher details.";
                }
            }
        } catch (Exception e) {
            message = "Error updating teacher details: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Teacher</title>
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

        const togglePassword = () => {
            const passwordInput = document.getElementById('password');
            const toggleButton = document.getElementById('togglePassword');
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            toggleButton.textContent = type === 'password' ? '👁️' : '🙈'; // Change icon based on visibility
        }
    </script>
</head>
<body>
    <header>
        <h1>Edit Teacher</h1>
    </header>
    <div class="main-content">
        <%
            if (message != null) {
                out.println("<p class='message'>" + message + "</p>");
            }
        %>
        <form action="<%= request.getRequestURI() %>" method="post" onsubmit="return validatePassword();">
            <input type="hidden" name="id" value="<%= teacherId %>">
            
            <label for="username">Username:</label>
            <input type="text" id="username" name="username" value="<%= username %>" required>
            
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
            <div id="passwordMessage" class="error"></div> <!-- Password validation message -->
            <span id="togglePassword" style="cursor: pointer;">👁️</span> <!-- Eye icon for toggling -->
            
            <label for="college">College:</label>
            <input type="text" id="college" name="college" value="<%= college %>" required>
            
            <label for="department">Department:</label>
            <input type="text" id="department" name="department" value="<%= department %>" required>
            
            <label for="year_id">Year:</label>
            <select id="year_id" name="year_id" required>
                <option value="">Select Year</option>
                <option value="1" <%= "1".equals(yearId) ? "selected" : "" %>>1</option>
                <option value="2" <%= "2".equals(yearId) ? "selected" : "" %>>2</option>
                <option value="3" <%= "3".equals(yearId) ? "selected" : "" %>>3</option>
                <option value="4" <%= "4".equals(yearId) ? "selected" : "" %>>4</option>
                <option value="5" <%= "5".equals(yearId) ? "selected" : "" %>>5</option>
            </select>
            
            <label for="semester">Semester:</label>
            <select id="semester" name="semester" required>
                <option value="">Select Semester</option>
                <option value="1" <%= "1".equals(semester) ? "selected" : "" %>>1</option>
                <option value="2" <%= "2".equals(semester) ? "selected" : "" %>>2</option>
            </select>
            
            <label for="course_name">Course Name:</label>
            <input type="text" id="course_name" name="course_name" value="<%= courseName %>" required>
            
            <button type="submit">Save Changes</button>
        </form>
        <form action="manage_teachers.jsp" method="get"> <!-- Redirect to Teacher List page -->
            <button type="submit" class="back-button">Back</button>
        </form>
    </div>
</body>
</html>