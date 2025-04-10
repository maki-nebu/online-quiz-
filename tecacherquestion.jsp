<%@ page import="java.sql.*, javax.servlet.http.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quiz Results</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        <h2 class="mt-5">Quiz Results</h2>

        <%
            HttpSession sessionObj = request.getSession();
            Integer studentId = (Integer) sessionObj.getAttribute("student_id");
            String courseIdStr = request.getParameter("course_id");
            int courseId;

            // Check if studentId is null
            if (studentId == null) {
                out.println("<h2 style='color: red;'>Error: You must be logged in to view results.</h2>");
                return; // Stop further processing
            }

            // Validate courseId
            if (courseIdStr == null || courseIdStr.isEmpty()) {
                out.println("<h2 style='color: red;'>Error: Invalid course ID.</h2>");
                return;
            }
            courseId = Integer.parseInt(courseIdStr);

            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

                // Fetch student's answers along with correct answers in a single query
                String query = "SELECT a.question_id, a.answer_text, a.answer_option, q.correct_answer " +
                               "FROM student_answers a " +
                               "JOIN questions q ON a.question_id = q.question_id " +
                               "WHERE a.student_id = ? AND a.course_id = ?";
                pstmt = conn.prepareStatement(query);
                pstmt.setInt(1, studentId);
                pstmt.setInt(2, courseId);
                rs = pstmt.executeQuery();

                List<Integer> questionIds = new ArrayList<>();
                List<String> studentAnswers = new ArrayList<>();
                List<String> correctAnswers = new ArrayList<>();
                int correctAnswersCount = 0;

                // Process results
                while (rs.next()) {
                    int questionId = rs.getInt("question_id");
                    String answerText = rs.getString("answer_text");
                    String answerOption = rs.getString("answer_option");
                    String correctAnswer = rs.getString("correct_answer");

                    // Store data
                    questionIds.add(questionId);
                    studentAnswers.add(answerOption != null ? answerOption : answerText);
                    correctAnswers.add(correctAnswer);

                    // Compare answers
                    if (answerOption != null ? answerOption.equalsIgnoreCase(correctAnswer) : answerText.equalsIgnoreCase(correctAnswer)) {
                        correctAnswersCount++;
                    }
                }

                // Calculate total score as a percentage
                int totalQuestions = questionIds.size();
                int score = (totalQuestions > 0) ? (correctAnswersCount * 100) / totalQuestions : 0;
        %>

        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th>Question ID</th>
                        <th>Your Answer</th>
                        <th>Correct Answer</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    for (int i = 0; i < questionIds.size(); i++) {
                    %>
                        <tr>
                            <td><%= questionIds.get(i) %></td>
                            <td><%= studentAnswers.get(i) %></td>
                            <td><%= correctAnswers.get(i) %></td>
                        </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>

        <h3>Total Questions: <%= totalQuestions %></h3>
        <h3>Correct Answers: <%= correctAnswersCount %></h3>
        <h3>Score: <%= score %>%</h3>

        <%
            } catch (SQLException e) {
                out.println("<h2 style='color: red;'>Database error: " + e.getMessage() + "</h2>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
            }
        %>
    </div>
</body>
</html>