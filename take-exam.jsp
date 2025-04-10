<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Start Quiz</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        .container {
            max-width: 600px;
            margin: auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            color: #333;
        }
        #timer {
            font-size: 20px;
            text-align: center;
            margin-bottom: 20px;
            color: #C62828; /* Red color for timer */
        }
        .question {
            margin: 20px 0;
        }
        .error {
            color: red;
            text-align: center;
        }
        button {
            display: block;
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        button:hover {
            background-color: #45a049;
        }
    </style>
    <script>
        function startTimer(duration) {
            let timer = duration, minutes, seconds;
            const display = document.querySelector('#timer');
            const form = document.getElementById("quizForm");
            const interval = setInterval(function () {
                minutes = parseInt(timer / 60, 10);
                seconds = parseInt(timer % 60, 10);
                minutes = minutes < 10 ? "0" + minutes : minutes;
                seconds = seconds < 10 ? "0" + seconds : seconds;
                display.textContent = minutes + ":" + seconds;

                if (--timer < 0) {
                    clearInterval(interval); // Stop the timer
                    alert("Time's up! Submitting your quiz.");
                    form.submit(); // Submit the form
                }
            }, 1000);
        }

        window.onload = function () {
            const duration = 60 * 2; // Set your timer duration here (e.g., 2 minutes)
            startTimer(duration);
        };
    </script>
</head>
<body>

<div class="container">

<%
    String examCode = request.getParameter("exam_code");
    String courseIdStr = request.getParameter("course_id");

    if (examCode == null || examCode.isEmpty() || courseIdStr == null || courseIdStr.isEmpty()) {
        out.println("<h2 class='error'>Exam code or course ID is missing.</h2>");
        return;
    }

    int courseId = Integer.parseInt(courseIdStr);
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
        String questionQuery = "SELECT question_id, question_text, question_type, option_1, option_2, option_3, option_4 FROM questions WHERE course_id = ?";
        pstmt = conn.prepareStatement(questionQuery);
        pstmt.setInt(1, courseId);
        rs = pstmt.executeQuery();

        List<Map<String, String>> questions = new ArrayList<>();

        while (rs.next()) {
            Map<String, String> question = new HashMap<>();
            question.put("id", rs.getString("question_id"));
            question.put("text", rs.getString("question_text"));
            question.put("type", rs.getString("question_type").toLowerCase());
            question.put("option1", rs.getString("option_1"));
            question.put("option2", rs.getString("option_2"));
            question.put("option3", rs.getString("option_3"));
            question.put("option4", rs.getString("option_4"));
            questions.add(question);
        }

        Collections.shuffle(questions);

        if (!questions.isEmpty()) {
%>
            <h1>Quiz Questions</h1>
            <div id="timer">02:00</div>
            <form id="quizForm" method="post" action="submit_exam.jsp">
                <input type="hidden" name="course_id" value="<%= courseId %>">
                <input type="hidden" name="exam_code" value="<%= examCode %>">
                <input type="hidden" name="student_id" value="1"> <!-- Replace with actual student ID -->
                <input type="hidden" name="total_questions" value="<%= questions.size() %>">

                <%
                for (Map<String, String> question : questions) {
                    String questionId = question.get("id");
                    String questionText = question.get("text");
                    String questionType = question.get("type");
                    String option1 = question.get("option1");
                    String option2 = question.get("option2");
                    String option3 = question.get("option3");
                    String option4 = question.get("option4");
                %>
                    <div class="question">
                        <p><strong><%= questionText %></strong></p>
                        <%
                        if (questionType.equals("true/false")) {
                        %>
                            <label>
                                <input type="radio" name="answer_option_<%= questionId %>" value="True" required> True
                            </label><br>
                            <label>
                                <input type="radio" name="answer_option_<%= questionId %>" value="False" required> False
                            </label><br>
                        <%
                        } else if (questionType.equals("mcq") || questionType.equals("multiple_choice")) {
                            if (option1 != null && !option1.trim().isEmpty()) {
                        %>
                                <label>
                                    <input type="radio" name="answer_option_<%= questionId %>" value="<%= option1.trim() %>" required>
                                    <%= option1.trim() %>
                                </label><br>
                        <%
                            }
                            if (option2 != null && !option2.trim().isEmpty()) {
                        %>
                                <label>
                                    <input type="radio" name="answer_option_<%= questionId %>" value="<%= option2.trim() %>" required>
                                    <%= option2.trim() %>
                                </label><br>
                        <%
                            }
                            if (option3 != null && !option3.trim().isEmpty()) {
                        %>
                                <label>
                                    <input type="radio" name="answer_option_<%= questionId %>" value="<%= option3.trim() %>" required>
                                    <%= option3.trim() %>
                                </label><br>
                        <%
                            }
                            if (option4 != null && !option4.trim().isEmpty()) {
                        %>
                                <label>
                                    <input type="radio" name="answer_option_<%= questionId %>" value="<%= option4.trim() %>" required>
                                    <%= option4.trim() %>
                                </label><br>
                        <%
                            }
                        } else if (questionType.equals("short answer")) {
                        %>
                            <input type="text" name="answer_text_<%= questionId %>" required><br>
                        <%
                        }
                        %>
                    </div>
                <%
                }
                %>
                <button type="submit">Submit Quiz</button>
            </form>
<%
        } else {
            out.println("<h2 class='error'>No questions found for this course.</h2>");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h2 class='error'>Database error: " + e.getMessage() + "</h2>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>

</div>
</body>
</html>