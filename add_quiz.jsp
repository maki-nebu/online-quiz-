<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Quiz and Questions</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        form {
            max-width: 800px;
            margin: auto;
        }
        label {
            font-weight: bold;
        }
        .question-block {
            border: 1px solid #ccc;
            padding: 10px;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <h2>Add Quiz</h2>
    <form action="add_question_process.jsp" method="POST">
        <!-- Quiz Details -->
        <label for="quiz_name">Quiz Name:</label><br>
        <input type="text" id="quiz_name" name="quiz_name" required><br><br>

        <label for="description">Description:</label><br>
        <textarea id="description" name="description" rows="4" required></textarea><br><br>

        <label for="quiz_time">Quiz Time (HH:MM:SS):</label><br>
        <input type="time" id="quiz_time" name="quiz_time" required><br><br>

        <label for="time_limit">Time Limit (minutes):</label><br>
        <input type="number" id="time_limit" name="time_limit" required><br><br>

        <label for="course_id">Course:</label><br>
        <select id="course_id" name="course_id" required>
            <% 
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/quiz_system", "root", "mysql");
                    String query = "SELECT course_id, course_name FROM courses";
                    pstmt = conn.prepareStatement(query);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        int courseId = rs.getInt("course_id");
                        String courseName = rs.getString("course_name");
            %>
                        <option value="<%= courseId %>"><%= courseName %></option>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                    if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
                }
            %>
        </select><br><br>

        <h3>Add Questions</h3>
        <div id="questions-container">
            <div class="question-block">
                <label for="question_text">Question Text:</label><br>
                <textarea name="question_text[]" required></textarea><br><br>

                <label for="question_type">Question Type:</label><br>
                <select name="question_type[]" required>
                    <option value="Multiple Choice">Multiple Choice</option>
                    <option value="Fill-in-the-Blank">Fill-in-the-Blank</option>
                    <option value="True/False">True/False</option>
                    <option value="Short Answer">Short Answer</option>
                </select><br><br>

                <div class="options">
                    <label>Options (for Multiple Choice only):</label><br>
                    <input type="text" name="option_1[]" placeholder="Option 1"><br>
                    <input type="text" name="option_2[]" placeholder="Option 2"><br>
                    <input type="text" name="option_3[]" placeholder="Option 3"><br>
                    <input type="text" name="option_4[]" placeholder="Option 4"><br>
                    <label for="correct_option">Correct Option (1-4):</label><br>
                    <input type="number" name="correct_option[]" min="1" max="4"><br><br>
                </div>

                <label for="correct_answer">Correct Answer (for non-MCQs):</label><br>
                <textarea name="correct_answer[]"></textarea><br><br>
            </div>
        </div>
        <button type="button" onclick="addQuestion()">Add Another Question</button><br><br>
        <button type="submit">Save Quiz</button>
    </form>

    <script>
        function addQuestion() {
            const container = document.getElementById('questions-container');
            const questionBlock = container.firstElementChild.cloneNode(true);
            questionBlock.querySelectorAll('input, textarea').forEach(input => input.value = '');
            container.appendChild(questionBlock);
        }
    </script>
</body>
</html>
