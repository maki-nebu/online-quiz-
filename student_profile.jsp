<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Profile</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
        }
        .profile-container {
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            color: #333;
        }
        .profile-info p {
            font-size: 16px;
            margin: 10px 0;
        }
        .profile-info p span {
            font-weight: bold;
        }
        .change-password {
            margin-top: 30px;
            padding: 20px;
            background: #f1f1f1;
            border-radius: 8px;
        }
        .change-password input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .change-password button {
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .change-password button:hover {
            background-color: #0056b3;
        }
        .message {
            color: green;
            font-weight: bold;
            margin: 20px 0;
        }
        .error {
            color: red;
            font-weight: bold;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="profile-container">
        <h1>Student Profile</h1>

        <% 
            String successMessage = null;
            String errorMessage = null;

            // Handling password change
            if (request.getMethod().equalsIgnoreCase("POST")) {
                String username = (String) session.getAttribute("username");
                String currentPassword = request.getParameter("current_password");
                String newPassword = request.getParameter("new_password");
                String confirmPassword = request.getParameter("confirm_password");

                // Password validation
                if (username == null) {
                    errorMessage = "You need to log in to change your password.";
                } else if (!newPassword.equals(confirmPassword)) {
                    errorMessage = "New passwords do not match. Please try again.";
                } else if (newPassword.length() < 8 || 
                           !newPassword.matches(".*[A-Z].*") || 
                           !newPassword.matches(".*[0-9].*")) {
                    errorMessage = "Password must be at least 8 characters, include an uppercase letter and a number.";
                } else {
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                        PreparedStatement stmt = con.prepareStatement("SELECT password FROM student_table WHERE username = ?");
                        stmt.setString(1, username);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
                            String dbPassword = rs.getString("password");
                            if (!dbPassword.equals(currentPassword)) {
                                errorMessage = "Current password is incorrect.";
                            } else {
                                stmt = con.prepareStatement("UPDATE student_table SET password = ? WHERE username = ?");
                                stmt.setString(1, newPassword);
                                stmt.setString(2, username);
                                stmt.executeUpdate();
                                successMessage = "Password changed successfully!";
                            }
                        } else {
                            errorMessage = "User not found.";
                        }
                    } catch (SQLException e) {
                        errorMessage = "Error changing password: " + e.getMessage();
                    }
                }
            }
        %>

        <% if (successMessage != null) { %>
            <div class="message"><%= successMessage %></div>
        <% } else if (errorMessage != null) { %>
            <div class="error"><%= errorMessage %></div>
        <% } %>

        <div class="profile-info">
            <% 
                String username = (String) session.getAttribute("username"); 
                if (username != null) {
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                        PreparedStatement stmt = con.prepareStatement("SELECT student_id, username, year_id, semester, college, department FROM student_table WHERE username = ?");
                        stmt.setString(1, username);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
            %>
                            <p><span>Student ID:</span> <%= rs.getInt("student_id") %></p>
                            <p><span>Username:</span> <%= rs.getString("username") %></p>
                            <p><span>Year:</span> <%= rs.getInt("year_id") %></p>
                            <p><span>Semester:</span> <%= rs.getInt("semester") %></p>
                            <p><span>College:</span> <%= rs.getString("college") %></p>
                            <p><span>Department:</span> <%= rs.getString("department") %></p>
            <% 
                        } else { 
            %>
                            <p>No profile data available or you are not a student.</p>
            <% 
                        }
                    } catch (SQLException e) {
                        errorMessage = "Error fetching profile: " + e.getMessage();
                    }
                } else { 
            %>
                <p>Please log in to view your profile.</p>
            <% } %>
        </div>

        <div class="change-password">
            <h2>Change Password</h2>
            <form method="POST">
                <input type="password" name="current_password" placeholder="Current Password" required>
                <input type="password" name="new_password" placeholder="New Password" required>
                <input type="password" name="confirm_password" placeholder="Confirm New Password" required>
                <button type="submit">Change Password</button>
            </form>
        </div>
    </div>
</body>
</html>