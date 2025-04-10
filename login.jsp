<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.HashMap" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
  <style>
        body {
            font-family: Arial, sans-serif;
            height: 100vh;
            margin: 0;
            overflow: hidden;
            position: relative;
        }
        .background {
            background-image: url('https://png.pngtree.com/thumb_back/fw800/background/20220828/pngtree-college-students-in-a-computer-lab-four-people-student-computers-photo-image_540695.jpg');
            background-size: cover;
            background-position: center;
            height: 100%;
            filter: blur(5px);
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            z-index: 0;
        }
        .container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
            width: 300px;
            position: relative;
            z-index: 1;
            border: 2px solid #3498db;
            margin: auto;
            top: 50%;
            transform: translateY(-50%);
        }
        h2 {
            text-align: center;
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
        }
        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .password-toggle {
            display: flex;
            align-items: center;
        }
        .password-toggle button {
            background: none;
            border: none;
            cursor: pointer;
            margin-left: -30px;
            outline: none;
        }
        button {
            width: 100%;
            padding: 10px;
            background-color: #3498db;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        button:hover {
            background-color: #2980b9;
        }
        .message {
            text-align: center;
            color: red;
            margin-top: 10px;
        }
        .password-message {
            font-size: 12px;
            color: red;
            margin-bottom: 10px;
        }
        .password-message.valid {
            color: green;
        }
    </style>
    <script>
        // Validate password as user types
        function validatePassword() {
            const passwordField = document.getElementById("password");
            const passwordMessage = document.getElementById("password-message");
            const password = passwordField.value;

            const regex = /^(?=.*[A-Z])(?=.*\d).{8,}$/; // At least 8 chars, 1 uppercase, 1 number
            if (regex.test(password)) {
                passwordMessage.textContent = "Password is valid!";
                passwordMessage.classList.add("valid");
                passwordMessage.classList.remove("invalid");
            } else {
                passwordMessage.textContent = "Password must be at least 8 characters, include an uppercase letter and a number.";
                passwordMessage.classList.remove("valid");
            }
        }

        // Toggle password visibility
        function togglePasswordVisibility() {
            const passwordField = document.getElementById("password");
            const eyeIcon = document.getElementById("eye-icon");

            if (passwordField.type === "password") {
                passwordField.type = "text";
                eyeIcon.innerHTML = `<path d="M12 5c-5.523 0-10 6-10 6s4.477 6 10 6 10-6 10-6-4.477-6-10-6zm0 10a4 4 0 110-8 4 4 0 010 8z"/>`;
            } else {
                passwordField.type = "password";
                eyeIcon.innerHTML = `<path d="M12 5c-5.523 0-10 6-10 6s4.477 6 10 6 10-6 10-6-4.477-6-10-6zm0 10a4 4 0 110-8 4 4 0 010 8zm-6.364-6a7.953 7.953 0 011.379-2.04l-1.415-1.414a10.053 10.053 0 00-1.95 3.54l1.986.914z"/>`;
            }
        }
    </script>
</head>
<body>
    <div class="background"></div>
    <div class="container">
        <h2>Login</h2>
        <%
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String message = "";

            HttpSession userSession = request.getSession();
            HashMap<String, Integer> attemptCounts = (HashMap<String, Integer>) userSession.getAttribute("attemptCounts");
            if (attemptCounts == null) {
                attemptCounts = new HashMap<>();
            }

            Integer attemptCount = attemptCounts.get(username);
            if (attemptCount == null) {
                attemptCount = 0;
            }

            if (attemptCount >= 4) {
                message = "Your account is locked due to too many failed login attempts. Please try again later.";
            } else {
                if (username != null && password != null) {
                    Connection conn = null;
                    try {
                        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

                        // Check admin credentials
                        String query = "SELECT * FROM admin_table WHERE username=? AND password=?";
                        PreparedStatement stmt = conn.prepareStatement(query);
                        stmt.setString(1, username);
                        stmt.setString(2, password);
                        System.out.println("Executing admin query for username: " + username);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
                            System.out.println("Admin login successful for username: " + username);
                            userSession.setAttribute("username", username);
                            userSession.setAttribute("admin_id", rs.getString("admin_id")); // Use admin_id for session management
                            attemptCounts.put(username, 0);
                            response.sendRedirect("adminDashboard.jsp");
                        } else {
                            // Check student credentials
                            query = "SELECT * FROM student_table WHERE username=? AND password=?";
                            stmt = conn.prepareStatement(query);
                            stmt.setString(1, username);
                            stmt.setString(2, password);
                            System.out.println("Executing student query for username: " + username);
                            rs = stmt.executeQuery();

                            if (rs.next()) {
                                System.out.println("Student login successful for username: " + username);
                                userSession.setAttribute("username", username);
                                userSession.setAttribute("student_id", rs.getString("student_id")); // Set student_id in session
                                attemptCounts.put(username, 0);
                                response.sendRedirect("studentDashboard.jsp");
                            } else {
                                attemptCount++;
                                attemptCounts.put(username, attemptCount);
                                message = "Invalid username or password.";
                                System.out.println("Invalid login attempt for username: " + username);
                            }
                        }
                    } catch (SQLException e) {
                        System.err.println("SQL State: " + e.getSQLState());
                        System.err.println("Error Code: " + e.getErrorCode());
                        System.err.println("Message: " + e.getMessage());
                        message = "Database error. Please try again later.";
                    } finally {
                        if (conn != null) {
                            try {
                                conn.close();
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }
            }

            userSession.setAttribute("attemptCounts", attemptCounts);
        %>

        <p class="message"><%= message %></p>

        <!-- Login Form -->
        <% if (attemptCount < 4) { %>
        <form action="login.jsp" method="POST">
            <label for="username">Username: </label>
            <input type="text" name="username" required>

            <label for="password">Password: </label>
            <div class="password-toggle">
                <input type="password" name="password" id="password" oninput="validatePassword();" required>
                <button type="button" id="toggle-password" onclick="togglePasswordVisibility();">
                    <svg id="eye-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" fill="#555">
                        <path d="M12 5c-5.523 0-10 6-10 6s4.477 6 10 6 10-6 10-6-4.477-6-10-6zm0 10a4 4 0 110-8 4 4 0 010 8z"/>
                    </svg>
                </button>
            </div>
            <p id="password-message" class="password-message">Password must be at least 8 characters, include an uppercase letter and a number.</p>

            <button type="submit">Login</button>
                <div style="text-align: center; margin-top: 20px;">
        <button onclick="window.history.back()" 
                style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; border-radius: 5px; cursor: pointer;">
            Back
        </button>
    </div>

        </form>
        <% } %>
    </div>
</body>
</html>