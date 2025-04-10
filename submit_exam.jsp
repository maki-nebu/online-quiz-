<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<!DOCTYPE html>
<html>
<head>
    <title>Submit Exam</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
        }
        h2 {
            color: #333;
        }
        .container {
            max-width: 600px;
            margin: auto;
            background: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        .alert {
            color: red;
        }
        .score {
            font-size: 1.2em;
            color: green;
        }
        .back-button {
            display: block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #007BFF;
            color: white;
            text-decoration: none;
            text-align: center;
            border-radius: 5px;
            font-size: 16px;
        }
        .back-button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
<div class="container">
<%
    // Ensure the session exists
    session.setMaxInactiveInterval(30 * 60); // 30 minutes
    String loggedStudentId = (String) session.getAttribute("student_id");
    
    if (loggedStudentId == null) {
        out.println("<h2 class='alert'>You are not logged in. Please log in to take the exam.</h2>");
        return;
    }

    int studentId = Integer.parseInt(loggedStudentId);
    String examCode = request.getParameter("exam_code");
    String courseIdStr = request.getParameter("course_id");
    int score = 0;

    if (examCode == null || examCode.isEmpty() || courseIdStr == null || courseIdStr.isEmpty()) {
        out.println("<h2 class='alert'>Exam code or course ID is missing.</h2>");
        return;
    }

    int courseId = Integer.parseInt(courseIdStr);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Connect to the database
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

        // Verify the student exists in the database
        String studentQuery = "SELECT username FROM student_table WHERE student_id = ?";
        pstmt = conn.prepareStatement(studentQuery);
        pstmt.setInt(1, studentId);
        rs = pstmt.executeQuery();

        String username = null;
        if (rs.next()) {
            username = rs.getString("username");
        } else {
            out.println("<h2 class='alert'>Logged-in student does not exist in the database.</h2>");
            return;
        }

        // Retrieve course data from the course table
        String courseQuery = "SELECT course_name FROM courses WHERE course_id = ?";
        pstmt = conn.prepareStatement(courseQuery);
        pstmt.setInt(1, courseId);
        rs = pstmt.executeQuery();

        String courseName = null;
        if (rs.next()) {
            courseName = rs.getString("course_name");
        } else {
            out.println("<h2 class='alert'>Course with ID " + courseId + " does not exist in the database.</h2>");
            return;
        }

        // Fetch the questions for the given course
        String questionQuery = "SELECT question_id, correct_option FROM questions WHERE course_id = ?";
        pstmt = conn.prepareStatement(questionQuery);
        pstmt.setInt(1, courseId);
        rs = pstmt.executeQuery();

        List<Map<String, String>> questions = new ArrayList<>();

        while (rs.next()) {
            Map<String, String> question = new HashMap<>();
            question.put("id", rs.getString("question_id"));
            question.put("correct_option", rs.getString("correct_option"));
            questions.add(question);
        }

        int totalQuestions = questions.size();

        // Prepare the insert statement for student answers
        String insertAnswerQuery = "INSERT INTO student_answers (student_id, question_id, answer_option, course_id) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insertAnswerQuery);

        for (Map<String, String> question : questions) {
            String questionId = question.get("id");
            String correctOption = question.get("correct_option");

            // Retrieve the answer option from the request
            String answerOption = request.getParameter("answer_option_" + questionId);

            if (answerOption != null) {
                pstmt.setInt(1, studentId);
                pstmt.setInt(2, Integer.parseInt(questionId));
                pstmt.setString(3, answerOption);
                pstmt.setInt(4, courseId);
                pstmt.executeUpdate();

                // Calculate the score
                if (correctOption.equals(answerOption)) {
                    score++;
                }
            }
        }

        // Display the score
        out.println("<h2 class='score'>Your Score: " + score + " out of " + totalQuestions + "</h2>");

        // Check if the result already exists
        String checkResultQuery = "SELECT COUNT(*) FROM results WHERE student_id = ? AND course_id = ?";
        pstmt = conn.prepareStatement(checkResultQuery);
        pstmt.setInt(1, studentId);
        pstmt.setInt(2, courseId);
        rs = pstmt.executeQuery();

        int count = 0;
        if (rs.next()) {
            count = rs.getInt(1);
        }

        if (count > 0) {
            out.println("<h2 class='alert'>Result already submitted for this course.</h2>");
        } else {
            // Insert the result into the results table
            String insertResultQuery = "INSERT INTO results (student_id, course_id, score, course_name, username) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pstmtResult = conn.prepareStatement(insertResultQuery)) {
                pstmtResult.setInt(1, studentId);
                pstmtResult.setInt(2, courseId);
                pstmtResult.setInt(3, score);
                pstmtResult.setString(4, courseName);
                pstmtResult.setString(5, username); // Store the username
                pstmtResult.executeUpdate();
                out.println("<h2 class='success'>Result saved successfully!</h2>");
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<h2 class='alert'>Error saving the result: " + e.getMessage() + "</h2>");
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h2 class='alert'>Database error: " + e.getMessage() + "</h2>");
    } finally {
        // Close resources
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>
    <a href="studentDashboard.jsp" class="back-button">Back to Dashboard</a>
</div>
</body>
</html>
