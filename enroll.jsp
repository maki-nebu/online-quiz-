<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="javax.servlet.http.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Enrollment</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<%
    // Retrieve the course_id from the form submission
    String courseIdStr = request.getParameter("course_id");
    if (courseIdStr == null) {
        out.println("<p>Course not found. Please try again.</p>");
        return;
    }
    
    int courseId = Integer.parseInt(courseIdStr);
    
    // Fetch course details from the database based on course_id
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
        
        // Query for course details
        String courseQuery = "SELECT course_name, department_name, teacher_name, quiz_instructions, question_type, quiz_time, year " +
                             "FROM courses WHERE course_id = ?";
        pstmt = conn.prepareStatement(courseQuery);
        pstmt.setInt(1, courseId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String courseName = rs.getString("course_name");
            String departmentName = rs.getString("department_name");
            String teacherName = rs.getString("teacher_name");
            String quizInstructions = rs.getString("quiz_instructions");
            String questionType = rs.getString("question_type");
            int quizTime = rs.getInt("quiz_time");
            String year = rs.getString("year");
            
%>
            <h1>Course Enrollment</h1>
            <h2>Course: <%= courseName %></h2>
            <p><strong>Department:</strong> <%= departmentName %></p>
            <p><strong>Teacher:</strong> <%= teacherName %></p>
            <p><strong>Quiz Instructions:</strong> <%= quizInstructions %></p>
            <p><strong>Question Type:</strong> <%= questionType %></p>
            <p><strong>Quiz Time:</strong> <%= quizTime %> minutes</p>
            <p><strong>Year:</strong> <%= year %></p>
            
            <!-- Form to input exam code -->
            <form action="take-exam.jsp" method="post">
                <label for="exam_code">Enter Exam Code:</label>
                <input type="text" name="exam_code" id="exam_code" required><br>
                <input type="hidden" name="course_id" value="<%= courseId %>">
                <button type="submit">Start Quiz</button>
            </form>
            
<%
        } else {
            out.println("<p>Course not found. Please try again.</p>");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<p>Database error: " + e.getMessage() + "</p>");
    } finally {
        // Clean up resources
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

</body>
</html>
