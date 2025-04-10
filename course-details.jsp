<%@ page import="java.sql.*, javax.servlet.http.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Course Details</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #eef2f3;
            color: #333;
        }
        h1 {
            color: #4a4a4a;
            text-align: center;
            margin-bottom: 20px;
        }
        h2 {
            color: #2c3e50;
        }
        p {
            font-size: 16px;
            line-height: 1.6;
            margin: 10px 0;
        }
        form {
            max-width: 450px;
            margin: 20px auto;
            padding: 20px;
            background-color: #ffffff;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: box-shadow 0.3s;
        }
        form:hover {
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        }
        label {
            display: block;
            margin-bottom: 10px;
            font-weight: bold;
            font-size: 14px;
            color: #34495e;
        }
        input[type="text"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border: 1px solid #bdc3c7;
            border-radius: 5px;
            font-size: 16px;
            transition: border-color 0.3s, box-shadow 0.3s;
            display: none; /* Initially hidden */
        }
        input[type="text"]:focus {
            border-color: #3498db;
            box-shadow: 0 0 5px rgba(52, 152, 219, 0.5);
            outline: none;
        }
        button {
            background-color: #3498db;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            transition: background-color 0.3s, transform 0.2s;
        }
        button:hover {
            background-color: #2980b9;
            transform: translateY(-2px);
        }
        button:active {
            transform: translateY(0);
        }
        .error {
            color: red;
            text-align: center;
            margin-top: 20px;
        }
    </style>
</head>
<body>

<%
    // Retrieve the course_name parameter from the request
    String courseName = request.getParameter("course_name");

    // Check if course_name is null or empty
    if (courseName == null || courseName.isEmpty()) {
        out.println("<h2 class='error'>Course name is missing. Please select a course.</h2>");
        return; // Stop further processing
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Establish database connection
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

        // Prepare SQL query to fetch course details based on course_name
        String courseQuery = "SELECT course_id, department_name, teacher_name, quiz_instructions, question_type, quiz_time, exam_code FROM courses WHERE course_name = ?";
        pstmt = conn.prepareStatement(courseQuery);
        pstmt.setString(1, courseName);
        rs = pstmt.executeQuery();

        // Check if the course exists
        if (rs.next()) {
            int courseId = rs.getInt("course_id");
            String departmentName = rs.getString("department_name");
            String teacherName = rs.getString("teacher_name");
            String quizInstructions = rs.getString("quiz_instructions");
            String questionType = rs.getString("question_type");
            int quizTime = rs.getInt("quiz_time");
            String examCode = rs.getString("exam_code"); // Get exam code

%>

            <h1>Course Details</h1>
            <h2>Course: <%= courseName %></h2>
            <p><strong>Department:</strong> <%= departmentName %></p>
            <p><strong>Teacher:</strong> <%= teacherName %></p>
            <p><strong>Quiz Instructions:</strong> <%= quizInstructions %></p>
            <p><strong>Question Type:</strong> <%= questionType %></p>
            <p><strong>Quiz Time:</strong> <%= quizTime %> minutes</p>

            <form method="post" action="take-exam.jsp">
                <label for="exam_code">Enter Exam Code:</label>
                <input type="text" id="exam_code" name="exam_code" required>
                <input type="hidden" name="course_id" value="<%= courseId %>">
                <input type="hidden" name="expected_exam_code" value="<%= examCode %>"> <!-- Store expected exam code -->
                <button type="submit">Start Quiz</button>
            </form>

            <script>
                // Show the exam code input field when the course details are displayed
                var examCodeInput = document.getElementById('exam_code');
                examCodeInput.style.display = 'block'; // Show the input field
                examCodeInput.value = ''; // Clear any previous value

                // Validate exam code on form submission
                document.querySelector('form').onsubmit = function() {
                    var enteredCode = examCodeInput.value;
                    var expectedCode = '<%= examCode %>'; // Get the expected exam code from JSP
                    if (enteredCode !== expectedCode) {
                        alert('The exam code you entered is incorrect. Please try again.');
                        return false; // Prevent form submission
                    }
                    return true; // Allow form submission
                };
            </script>

<%
        } else {
            out.println("<h2 class='error'>Course not found. Please ensure the course exists.</h2>");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h2 class='error'>Database error: " + e.getMessage() + "</h2>");
    } finally {
        // Clean up resources
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>

</body>
</html>