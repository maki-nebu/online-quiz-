<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>admin Dashboard</title>
    <style>
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
            height: 100vh; /* Full height */
            position: fixed; /* Fixed sidebar */
        }
        .sidebar h2 {
            margin: 0 0 20px;
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
            margin-left: 220px; /* Space for sidebar */
            padding: 20px;
            flex: 1; /* Take remaining space */
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
        .logout {
            background-color: #f44336;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .dashboard {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-top: 50px;
        }
        .card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
            padding: 20px;
            margin: 10px;
            text-align: center;
            flex: 1 1 200px; /* Responsive card width */
            transition: transform 0.2s;
        }
        .card:hover {
            transform: scale(1.05);
        }
        .status {
            font-size: 48px;
            color: #333;
            margin: 10px 0;
        }
        .card h3 {
            margin: 10px 0;
        }
        .btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 5px;
            margin: 10px 0;
            display: inline-block;
            font-size: 16px;
        }
        .btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>

    <!-- Sidebar -->
    <div class="sidebar">
        <h2>Admin Panel</h2>
        <a href="#">Dashboard</a>
        <a href="manage_students.jsp">Manage Students</a>
        <a href="manage_teachers.jsp">Manage Teachers</a>
        <a href="course.jsp">Manage Courses</a>
        <a href="quiz.jsp">Manage Quiz</a>
        <a href="admin_view_scores.jsp">Manage Results</a>
        <a href="admin_profile.jsp">Profile</a>
    </div>

    <!-- Content Area -->
    <div class="content">
        <!-- Navbar -->
        <div class="navbar">
            <h1> Dashboard</h1>
        </div>

        <!-- Quiz Options -->
        <div class="dashboard">
            <!-- Add Quiz Card -->
            <div class="card">
                <h3>Questions</h3>
                <p>allow questions for student </p>
                <a href="control.jsp" class="btn">view question</a>
            </div>

           

</body>
</html>
