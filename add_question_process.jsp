<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Process Questions</title>
</head>
<body>
<%
    // Database connection setup
    String dbURL = "jdbc:mysql://localhost:3305/quiz_system";
    String dbUser = "root";
    String dbPassword = "mysql";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

        // Retrieve form data
        String quizName = request.getParameter("quiz_name");
        String description = request.getParameter("description");
        String quizTime = request.getParameter("quiz_time");
        int timeLimit = Integer.parseInt(request.getParameter("time_limit"));
        int courseId = Integer.parseInt(request.getParameter("course_id"));
        String[] questionTexts = request.getParameterValues("question_text[]");
        String[] questionTypes = request.getParameterValues("question_type[]");
        String[] option1 = request.getParameterValues("option_1[]");
        String[] option2 = request.getParameterValues("option_2[]");
        String[] option3 = request.getParameterValues("option_3[]");
        String[] option4 = request.getParameterValues("option_4[]");
        String[] correctOptions = request.getParameterValues("correct_option[]");
        String[] correctAnswers = request.getParameterValues("correct_answer[]");

        // Insert quiz into database
        String quizQuery = "INSERT INTO quizzes (quiz_name, description, quiz_time, time_limit, course_id) VALUES (?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(quizQuery, Statement.RETURN_GENERATED_KEYS);
        pstmt.setString(1, quizName);
        pstmt.setString(2, description);
        pstmt.setString(3, quizTime);
        pstmt.setInt(4, timeLimit);
        pstmt.setInt(5, courseId);
        pstmt.executeUpdate();

        // Get the generated quiz ID
        ResultSet rs = pstmt.getGeneratedKeys();
        int quizId = 0;
        if (rs.next()) {
            quizId = rs.getInt(1);
        }

        // Insert questions into database
        String questionQuery = "INSERT INTO questions (quiz_id, question_text, question_type, option_1, option_2, option_3, option_4, correct_option, correct_answer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(questionQuery);

        for (int i = 0; i < questionTexts.length; i++) {
            pstmt.setInt(1, quizId);
            pstmt.setString(2, questionTexts[i]);
            pstmt.setString(3, questionTypes[i]);
            pstmt.setString(4, option1[i]);
            pstmt.setString(5, option2[i]);
            pstmt.setString(6, option3[i]);
            pstmt.setString(7, option4[i]);
            pstmt.setString(8, correctOptions[i]);
            pstmt.setString(9, correctAnswers[i]);
            pstmt.addBatch();
        }
        pstmt.executeBatch();

        out.println("<h3>Quiz and questions added successfully!</h3>");
    } catch (Exception e) {
        e.printStackTrace(out);
        out.println("<h3>Error: " + e.getMessage() + "</h3>");
    } finally {
        // Close resources
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace(out);
        }
    }
%>
</body>
</html>
