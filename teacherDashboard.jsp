<%@ page language="java" contentType="text/html; " %>
<%
    // Session check
    String user = (String) session.getAttribute("username");
    if (user == null) {
        response.sendRedirect("login.jsp"); // redirect if not logged in
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Dashboard</title>
    <style>
        /* your CSS unchanged */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            display: flex;
        }

        .sidebar {
            width: 200px;
            background-color: #333;
            color: white;
            padding: 15px;
            height: 100vh;
            position: fixed;
        }

        .sidebar h2 {
            margin-bottom: 20px;
        }

        .sidebar a {
            color: white;
            text-decoration: none;
            display: block;
            margin: 10px 0;
            padding: 10px;
        }

        .sidebar a:hover {
            background-color: #555;
        }

        .content {
            margin-left: 220px;
            padding: 20px;
            flex: 1;
        }

        .navbar {
            background-color: #444;
            color: white;
            padding: 15px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .navbar h1 {
            margin: 0;
        }

        .dashboard {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-around;
            margin-top: 20px;
        }

        .card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
            padding: 20px;
            margin: 10px;
            text-align: center;
            flex: 1 1 200px;
            transition: transform 0.2s;
        }

        .card:hover {
            transform: scale(1.05);
        }

        .card h3 {
            margin: 10px 0;
        }

        .logout {
            background-color: #f44336;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-align: center;
            display: block;
            width: 100%;
            text-decoration: none;
            text-align: center;
        }

        .logout:hover {
            background-color: #d32f2f;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <h2>Teacher Dashboard</h2>
        <a href="teacher_score.jsp">Manage Result</a>
        <a href="teacherprofile.jsp">Profile</a>
        <a href="logout.jsp" class="logout">Logout</a>
    </div>

    <!-- Main Content -->
    <div class="content">
        <!-- Navbar -->
        <div class="navbar">
            <h1>Welcome, <%= user %></h1> 
        </div>

        <!-- Dashboard -->
        <div class="dashboard">
            <!-- Profile Card -->
            <div class="card">
                <h3>Profile</h3>
                <p>View and edit your personal information</p>
                <a href="teacherprofile.jsp">Go to Profile</a>
            </div>

            <!-- Results Card -->
            <div class="card">
                <h3>Results</h3>
                <p>View and manage student results</p>
                <a href="result.jsp">Go to Results</a>
            </div>
        </div>
    </div>
</body>
</html>
