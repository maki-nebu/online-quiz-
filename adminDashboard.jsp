<%@ page import="java.sql.*" %>
<%@ page session="true" %>

    
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        header .logout-container {
            margin-left: 10px;
        }
        header h1 {
            margin: 0;
            flex: 1;
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
        form{margin-left: 70px;}
    </style>
</head>
<body>
    <header>
        <div class="logout-container">
            <form action="logout.jsp" method="post">
                <button type="submit" class="btn logout">Logout</button>
            </form>
        </div>
        <h1>Admin Dashboard</h1>
    </header>
    <div class="sidebar">
        <h1 style="color: white">Admin Dashboard</h1>

        <a href="manage_students.jsp">Manage Students</a>
        <a href="manage_teachers.jsp">Manage Teachers</a>
        <a href="course.jsp">Manage Courses</a>
        <a href="adminquiz.jsp">Manage Quiz</a>
        <a href="admin_view_scores.jsp">Manage Results</a>
        <a href="admin_profile.jsp">Profile</a>
         <form action="logout.jsp" method="post">
                <button type="submit" class="btn logout">Logout</button>
    </div>
    <div class="main-content">
        <%
            // Retrieve the username directly from the session
            String username = (String) session.getAttribute("username");
            if (username == null) {
                out.println("User not logged in.");
                return; // Optional: Redirect to login page if no username is found
            }
        %>
        <h2>Hello, <%= username %>!</h2>
        <p>Welcome to your admin dashboard. Here, you can manage students, teachers, courses, quizzes, and more.</p>
    </div>
</body>
</html>
