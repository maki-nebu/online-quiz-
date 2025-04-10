<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.PreparedStatement" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Courses and Questions</title>
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
            padding: 20px;
        }
        .course {
            background-color: #e7f1ff;
            padding: 10px;
            margin-top: 10px;
            cursor: pointer;
        }
        .questions {
            margin-left: 20px;
            display: none;
        }
        .question {
            background-color: #ffffff;
            border: 1px solid #ddd;
            padding: 8px;
            margin-top: 5px;
        }
        .btn {
            background-color: #dc3545;
            color: white;
            padding: 5px 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .btn:hover {
            background-color: #c82333;
        }
    </style>
    <script>
        function toggleQuestions(courseId) {
            const questionsDiv = document.getElementById(courseId);
            questionsDiv.style.display = questionsDiv.style.display === "none" || questionsDiv.style.display === "" ? "block" : "none";
        }
    </script>
</head>
<body>
    <header>
             <h1>Courses and Their Questions</h1>

    </header>
    <div class="main-content">
        <h1>Courses </h1>

        <% 
            Connection con = null;
            Statement stmt = null;
            ResultSet rs = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                stmt = con.createStatement();
                
                // Query to get distinct courses
                String courseQuery = "SELECT DISTINCT course_id, course_name, questions_accessible FROM courses";
                rs = stmt.executeQuery(courseQuery);
                
                while (rs.next()) {
                    int courseId = rs.getInt("course_id");
                    String courseName = rs.getString("course_name");
                    boolean questionsAccessible = rs.getBoolean("questions_accessible");
        %>
            <div class="course" onclick="toggleQuestions('questions_<%= courseId %>')">
                <strong><%= courseName %></strong>
                <form action="toggleQuestionsAccess.jsp" method="post" style="display:inline;">
                    <input type="hidden" name="course_id" value="<%= courseId %>">
                    <input type="checkbox" name="questions_accessible" value="1" <%= questionsAccessible ? "checked" : "" %> 
                    onchange="this.form.submit();">
                    <label> Allow Student Access</label>
                </form>
            </div>
            <div id="questions_<%= courseId %>" class="questions" style="<%= questionsAccessible ? "" : "display:none;" %>">
                <% 
                    // Query to get questions for the current course
                    String questionQuery = "SELECT * FROM questions WHERE course_id = " + courseId;
                    Statement questionStmt = con.createStatement();
                    ResultSet questionRs = questionStmt.executeQuery(questionQuery);
                    
                    while (questionRs.next()) {
                        int questionId = questionRs.getInt("question_id");
                        String questionText = questionRs.getString("question_text");
                        String option1 = questionRs.getString("option_1");
                        String option2 = questionRs.getString("option_2");
                        String option3 = questionRs.getString("option_3");
                        String option4 = questionRs.getString("option_4");
                %>
                    <div class="question">
                        <p><strong>Question ID:</strong> <%= questionId %></p>
                        <p><strong>Question:</strong> <%= questionText %></p>
                        <p><strong>Options:</strong> <%= option1 %>, <%= option2 %>, <%= option3 %>, <%= option4 %></p>
                        <form action="QuestionServlet" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= questionId %>">
                            <button type="submit" class="btn">Delete</button>
                        </form>
                    </div>
                <% 
                    }
                    questionRs.close();
                %>
            </div>
        <% 
                }
                rs.close();
            } catch (Exception e) {
                e.printStackTrace();
        %>
            <p>Error fetching courses and questions: <%= e.getMessage() %></p>
        <% 
            } finally {
                if (stmt != null) try { stmt.close(); } catch (SQLException ignore) {}
                if (con != null) try { con.close(); } catch (SQLException ignore) {}
            }
        %>
    </div>
    <div style="text-align: center; margin-top: 20px;">
        <button onclick="window.history.back()" 
                style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; border-radius: 5px; cursor: pointer;">
            Back
        </button>
    </div>
</body>
</html>