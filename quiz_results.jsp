<%@ page import="java.sql.*, javax.servlet.http.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Submit Quiz</title>
</head>
<body>

<%
    // Retrieve parameters from the request
    String examCode = request.getParameter("exam_code");
    String courseIdStr = request.getParameter("course_id");
    String studentIdStr = request.getParameter("student_id");
    String totalQuestionsStr = request.getParameter("total_questions");

    // Validate parameters
    if (examCode == null || courseIdStr == null || studentIdStr == null || totalQuestionsStr == null) {
        out.println("<h2 style='color: red;'>Missing parameters. Please fill out the quiz form correctly.</h2>");
        return;
    }

    int studentId = Integer.parseInt(studentIdStr);
    int totalQuestions = Integer.parseInt(totalQuestionsStr);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    int score = 0;

    try {
        // Establish database connection
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

        // Step 1: Get correct answers from the database
        String answerQuery = "SELECT question_id, correct_answer FROM questions WHERE course_id = ?";
        pstmt = conn.prepareStatement(answerQuery);
        pstmt.setInt(1, Integer.parseInt(courseIdStr));
        rs = pstmt.executeQuery();

        Map<Integer, String> correctAnswers = new HashMap<>();

        // Store correct answers in a map
        while (rs.next()) {
            correctAnswers.put(rs.getInt("question_id"), rs.getString("correct_answer"));
        }

        // Step 2: Calculate score based on submitted answers
        for (int i = 1; i <= totalQuestions; i++) {
            String submittedAnswer = request.getParameter("option_" + i);
            String correctAnswer = correctAnswers.get(i);

            if (correctAnswer != null && submittedAnswer != null && submittedAnswer.equals(correctAnswer)) {
                score++;
            }
        }

        // Step 3: Insert results into quiz_results
        String insertResultQuery = "INSERT INTO quiz_results (exam_code, course_id, student_id, total_questions, score) VALUES (?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insertResultQuery);
        pstmt.setString(1, examCode);
        pstmt.setInt(2, Integer.parseInt(courseIdStr));
        pstmt.setInt(3, studentId);
        pstmt.setInt(4, totalQuestions);
        pstmt.setInt(5, score);
        pstmt.executeUpdate(); // Execute insert for quiz results

        // Step 4: Display results
        out.println("<h1>Quiz Results</h1>");
        out.println("<table border='1'>");
        out.println("<tr><th>Total Questions</th><th>Score</th></tr>");
        out.println("<tr><td>" + totalQuestions + "</td><td>" + score + "</td></tr>");
        out.println("</table>");

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h2 style='color: red;'>Database error: " + e.getMessage() + "</h2>");
    } finally {
        // Close resources
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>

</body>
</html>