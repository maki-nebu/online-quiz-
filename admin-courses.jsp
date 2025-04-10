<%@ page import="java.sql.*, java.util.*" %>
<%
    String action = request.getParameter("action");
    String message = null;
    int courseId = -1;
    int totalQuizTimeInSeconds = 0; // Declare the variable here

    // Edit Course Logic
    if ("Edit".equals(action)) {
        courseId = Integer.parseInt(request.getParameter("course_id"));
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM courses WHERE course_id = ?")) {
            pstmt.setInt(1, courseId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                // Populate fields
                request.setAttribute("course_name", rs.getString("course_name"));
                request.setAttribute("department_name", rs.getString("department_name"));
                request.setAttribute("teacher_name", rs.getString("teacher_name"));
                request.setAttribute("quiz_instructions", rs.getString("quiz_instructions"));
                request.setAttribute("question_types", rs.getString("question_type").split(","));
                request.setAttribute("quiz_time", rs.getInt("quiz_time"));
                request.setAttribute("year", rs.getString("year"));
                request.setAttribute("semester", rs.getString("semester"));
            }
        } catch (SQLException e) {
            message = "Error fetching course details: " + e.getMessage();
        }
    }

    // Delete Course Logic
    if ("Delete".equals(action)) {
        courseId = Integer.parseInt(request.getParameter("course_id"));
        try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
             PreparedStatement pstmt = conn.prepareStatement("DELETE FROM courses WHERE course_id = ?")) {
            pstmt.setInt(1, courseId);
            pstmt.executeUpdate();
            message = "Course deleted successfully!";
        } catch (SQLException e) {
            message = "Error deleting course: " + e.getMessage();
        }
    }

    // Add and Update Course Logic
    if ("Add".equals(action) || "Update".equals(action)) {
        String courseName = request.getParameter("course_name");
        String departmentName = request.getParameter("department_name");
        String teacherName = request.getParameter("teacher_name");
        String quizInstructions = request.getParameter("quiz_instructions");
        String[] questionTypes = request.getParameterValues("question_types");
        String quizTimeInput = request.getParameter("quiz_time");
        String year = request.getParameter("year");
        String semester = request.getParameter("semester");

        // Validate and process quiz time input
        if (quizTimeInput != null && !quizTimeInput.isEmpty()) {
            String[] timeParts = quizTimeInput.split(":");
            if (timeParts.length == 3) {
                try {
                    int hours = Integer.parseInt(timeParts[0]);
                    int minutes = Integer.parseInt(timeParts[1]);
                    int seconds = Integer.parseInt(timeParts[2]);
                    totalQuizTimeInSeconds = (hours * 3600) + (minutes * 60) + seconds;

                    // Validate total quiz time
                    if (totalQuizTimeInSeconds < 60 || totalQuizTimeInSeconds > 300) {
                        message = "Quiz time must be between 00:01:00 and 00:05:00.";
                    }
                } catch (NumberFormatException e) {
                    message = "Invalid time format. Please enter valid numbers for hours, minutes, and seconds.";
                }
            } else {
                message = "Quiz time must be in HH:MM:SS format.";
            }
        } else {
            message = "Quiz time cannot be empty.";
        }

        // Server-side validation for year and semester
        if (message == null) {
            if (Integer.parseInt(year) < 1 || Integer.parseInt(year) > 5) {
                message = "Year must be between 1 and 5.";
            } else if (Integer.parseInt(semester) < 1 || Integer.parseInt(semester) > 2) {
                message = "Semester must be either 1 or 2.";
            }
        }

        // If there are no messages, proceed with the database operation
        if (message == null) {
            String questionTypeString = (questionTypes != null) ? String.join(",", questionTypes) : "";
            String examCode = "EX-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                String query;
                if ("Add".equals(action)) {
                    query = "INSERT INTO courses (course_name, department_name, teacher_name, quiz_instructions, question_type, quiz_time, year, semester, exam_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                } else {
                    query = "UPDATE courses SET course_name = ?, department_name = ?, teacher_name = ?, quiz_instructions = ?, question_type = ?, quiz_time = ?, year = ?, semester = ?, exam_code = ? WHERE course_id = ?";
                }

                try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                    pstmt.setString(1, courseName);
                    pstmt.setString(2, departmentName);
                    pstmt.setString(3, teacherName);
                    pstmt.setString(4, quizInstructions);
                    pstmt.setString(5, questionTypeString);
                    pstmt.setInt(6, totalQuizTimeInSeconds); // Now guaranteed to be initialized
                    pstmt.setString(7, year);
                    pstmt.setString(8, semester);
                    pstmt.setString(9, examCode);
                    if ("Update".equals(action)) {
                        pstmt.setInt(10, courseId);
                    }
                    pstmt.executeUpdate();
                    message = (action.equals("Add") ? "Course added successfully!" : "Course updated successfully!");
                }
                response.sendRedirect("admin-courses.jsp");
                return; // Exit the JSP to prevent further processing
            } catch (SQLException e) {
                message = "Error adding/updating course: " + e.getMessage();
            }
        }
    }
%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f9f9f9;
            color: #333;
        }
        h1, h2 {
            color: #0056b3;
            text-align: center;
        }
        form {
            background: #ffffff;
            padding: 20px;
            margin: 20px auto;
            border: 1px solid #ddd;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 600px;
        }
        label {
            display: block;
            margin: 10px 0 5px;
            font-weight: bold;
        }
        input[type="text"], input[type="number"], textarea, select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        button {
            background-color: #0056b3;
            color: #fff;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #004494;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        table th, table td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }
        table th {
            background-color: #0056b3;
            color: #fff;
        }
        table tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        table tr:hover {
            background-color: #d9eafc;
        }
        a {
            color: #0056b3;
            text-decoration: none;
            margin: 0 5px;
        }
        a:hover {
            text-decoration: underline;
        }
        .alert {
            background-color: #ffcccc;
            color: #a33;
            padding: 10px;
            border: 1px solid #ffaaaa;
            margin-bottom: 15px;
            border-radius: 4px;
        }
        h1 { background-color: #333; color: white; }
    </style>
    <title>Admin - Manage Courses</title>
    <script type="text/javascript">
        function validateForm() {
            var year = document.forms["courseForm"]["year"].value;
            var semester = document.forms["courseForm"]["semester"].value;
            var quizTime = document.forms["courseForm"]["quiz_time"].value;

            if (year < 1 || year > 5) {
                alert("Year must be between 1 and 5.");
                return false;
            }

            if (semester < 1 || semester > 2) {
                alert("Semester must be either 1 or 2.");
                return false;
            }

            // Regex to match HH:MM:SS format
            var timePattern = /^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/;
            if (!timePattern.test(quizTime)) {
                alert("Quiz time must be in HH:MM:SS format.");
                return false;
            }

            return true;
        }
    </script>
</head>
<body>
    <h1>Manage Courses</h1>
    
    <%
        if (message != null) {
            out.println("<div class='alert'>" + message + "</div>");
        }
    %>

    <h2><%= (courseId == -1 ? "Add New Course" : "Edit Course") %></h2>
    <form name="courseForm" action="admin-courses.jsp" method="post" onsubmit="return validateForm()">
        <input type="hidden" name="action" value="<%= (courseId == -1 ? "Add" : "Update") %>">
        
        <label for="course_name">Course Name:</label>
        <select name="course_name" id="course_name" required> 
            <option value="" disabled selected>Select a course</option>
            <%
                String selectedCourseName = request.getAttribute("course_name") != null ? request.getAttribute("course_name").toString() : null; 
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                     PreparedStatement pstmt = conn.prepareStatement("SELECT course_name FROM academic_courses");
                     ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        String courseName = rs.getString("course_name");
            %>
            <option value="<%= courseName %>" <%= selectedCourseName != null && selectedCourseName.equals(courseName) ? "selected" : "" %>><%= courseName %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error fetching courses: " + e.getMessage() + "</p>");
                }
            %>
        </select><br>

        <label for="department_name">Department Name:</label>
        <input type="text" name="department_name" id="department_name" required value="<%= request.getAttribute("department_name") != null ? request.getAttribute("department_name") : "" %>"><br>

        <label for="teacher_name">Teacher Name:</label>
        <select name="teacher_name" id="teacher_name" required>
            <option value="" disabled selected>Select a teacher</option>
            <%
                String selectedTeacherName = request.getAttribute("teacher_name") != null ? request.getAttribute("teacher_name").toString() : null; 
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                     PreparedStatement pstmt = conn.prepareStatement("SELECT username FROM teacher_table");
                     ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        String teacherName = rs.getString("username");
            %>
                        <option value="<%= teacherName %>" <%= selectedTeacherName != null && selectedTeacherName.equals(teacherName) ? "selected" : "" %>><%= teacherName %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("<p>Error fetching teachers: " + e.getMessage() + "</p>");
                }
            %>
        </select><br>

        <label for="quiz_instructions">Quiz Instructions:</label>
        <textarea name="quiz_instructions" id="quiz_instructions" required><%= request.getAttribute("quiz_instructions") != null ? request.getAttribute("quiz_instructions") : "" %></textarea><br>

        <label for="question_types">Question Types:</label><br>
        <input type="checkbox" name="question_types" value="multiple_choice" id="mcq"> 
        <label for="mcq">Multiple Choice</label><br>
      
       

        <label for="quiz_time">Quiz Time (HH:MM:SS):</label>
        <input type="text" name="quiz_time" id="quiz_time" required placeholder="HH:MM:SS" 
               pattern="^(0[0-9]|1[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])$" 
               title="Format must be HH:MM:SS" 
               value="<%= request.getAttribute("quiz_time") != null ? String.format("%02d:%02d:%02d", ((Integer) request.getAttribute("quiz_time")) / 3600, (((Integer) request.getAttribute("quiz_time")) % 3600) / 60, ((Integer) request.getAttribute("quiz_time")) % 60) : "" %>">
        <br>

        <label for="year">Year:</label>
        <input type="text" name="year" id="year" required value="<%= request.getAttribute("year") != null ? request.getAttribute("year") : "" %>"><br>

        <label for="semester">Semester:</label>
        <input type="number" name="semester" id="semester" required value="<%= request.getAttribute("semester") != null ? request.getAttribute("semester") : "" %>"><br>

        <button type="submit">Submit</button>
    </form>

    <h2>Existing Courses</h2>
    <table>
        <thead>
            <tr>
                <th>Course Name</th>
                <th>Department Name</th>
                <th>Teacher Name</th>
                <th>Quiz Instructions</th>
                <th>Question Types</th>
                <th>Quiz Time</th>
                <th>Year</th>
                <th>Semester</th>
                <th>Exam Code</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <%
                try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                     PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM courses");
                     ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
            %>
            <tr>
                <td><%= rs.getString("course_name") %></td>
                <td><%= rs.getString("department_name") %></td>
                <td><%= rs.getString("teacher_name") %></td>
                <td><%= rs.getString("quiz_instructions") %></td>
                <td><%= rs.getString("question_type") %></td>
                <td><%= String.format("%02d:%02d:%02d", rs.getInt("quiz_time") / 3600, (rs.getInt("quiz_time") % 3600) / 60, rs.getInt("quiz_time") % 60) %></td>
                <td><%= rs.getString("year") %></td>
                <td><%= rs.getString("semester") %></td>
                <td><%= rs.getString("exam_code") %></td>
                <td>
                    <a href="edit-course.jsp?action=Edit&course_id=<%= rs.getInt("course_id") %>">Edit</a>
                    <a href="admin-courses.jsp?action=Delete&course_id=<%= rs.getInt("course_id") %>" onclick="return confirm('Are you sure you want to delete this course?')">Delete</a>
                </td>
            </tr>
            <% 
                    }
                } catch (SQLException e) {
                    out.println("<p>Error fetching courses: " + e.getMessage() + "</p>");
                }
            %>
        </tbody>
    </table>
</body>
</html>