<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
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
        .sidebar {
            height: 100vh;
            width: 200px;
            background-color: #333;
            position: fixed;
            top: 0;
            left: 0;
            padding-top: 20px;
        }
        .sidebar a {
            padding: 15px;
            text-decoration: none;
            color: white;
            display: block;
            text-align: center;
        }
        .sidebar a:hover {
            background-color: #ddd;
            color: black;
        }
        .main-content {
            margin-left: 220px; /* Space for sidebar */
            padding: 20px;
        }
        .cards {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
        }
        .card {
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin: 10px;
            flex: 1;
            min-width: 200px; /* Minimum width for responsiveness */
            text-align: center;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin: 10px 0;
            background-color: #007BFF;
            color: white;
            border: none;
            text-decoration: none;
            cursor: pointer;
            text-align: center;
            border-radius: 5px;
        }
        .btn:hover {
            background-color: #0056b3;
        }
        .logout {
            background-color: red;
        }
        .logout:hover {
            background-color: darkred;
        }
    </style>
</head>
<body>
    <header>
        <h1>Student Dashboard</h1>
    </header>
    <div class="sidebar">
        <h1 style="color: white">Student Dashboard</h1>

        <a href="student-course-select.jsp">Take Quiz</a>
        <a href="student_score.jsp">View Results</a>
<a href="logout.jsp" class="btn logout">Logout</a>    </div>
    <div class="main-content">
        <% 
            // Session validation using the existing session object
            if (session == null || session.getAttribute("username") == null) {
                response.sendRedirect("login.jsp"); // Redirect to login page if session is invalid
                return; // Stop further processing
            }
            String username = (String) session.getAttribute("username");
            String studentId = (String) session.getAttribute("student_id");
        %>
        <h2>Hello, <%= username %>!</h2>
        <p>Welcome to your dashboard. Here, you can manage your quizzes, view results, and update your profile.</p>

        <div>
            <a href="student-course-select.jsp?student_id=<%= studentId %>" class="btn">Take a Quiz</a>
            <a href="student_profile.jsp?student_id=<%= studentId %>" class="btn">Profile</a>
        </div>
    </div>
</body>
</html>
