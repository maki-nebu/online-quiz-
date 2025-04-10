<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.security.MessageDigest" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Teacher Profile</title>
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
    <script>
        function validatePassword() {
            const newPassword = document.getElementsByName("new_password")[0].value;
            const confirmPassword = document.getElementsByName("confirm_password")[0].value;
            const errorMessage = document.getElementById("passwordError");

            const regex = /^(?=.*[A-Z])(?=.*\d).{8,}$/; // At least 8 chars, 1 uppercase, 1 number

            if (newPassword.length < 8 || !regex.test(newPassword)) {
                errorMessage.textContent = "New password must be at least 8 characters, include an uppercase letter and a number.";
                return false;
            } else if (newPassword !== confirmPassword) {
                errorMessage.textContent = "New passwords do not match.";
                return false;
            } else {
                errorMessage.textContent = "";
                return true;
            }
        }
    </script>
</head>
<body>
    <div class="profile-container">
        <h1>Teacher Profile</h1>

        <% 
            String successMessage = null;
            String errorMessage = null;

            // Handling password change
            if (request.getMethod().equalsIgnoreCase("POST")) {
                String username = (String) session.getAttribute("username");
                String currentPassword = request.getParameter("current_password");
                String newPassword = request.getParameter("new_password");
                String confirmPassword = request.getParameter("confirm_password");

                if (username == null) {
                    errorMessage = "You need to log in to change your password.";
                } else if (!newPassword.equals(confirmPassword)) {
                    errorMessage = "New passwords do not match. Please try again.";
                } else {
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                        PreparedStatement stmt = con.prepareStatement("SELECT password FROM teacher_table WHERE username = ?");
                        stmt.setString(1, username);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
                            String dbPassword = rs.getString("password");
                            // Hash current password for comparison
                            MessageDigest md = MessageDigest.getInstance("SHA-256");
                            byte[] currentHashedBytes = md.digest(currentPassword.getBytes("UTF-8"));
                            StringBuilder currentHashedPassword = new StringBuilder();
                            for (byte b : currentHashedBytes) {
                                currentHashedPassword.append(String.format("%02x", b));
                            }

                            if (!currentHashedPassword.toString().equals(dbPassword)) {
                                errorMessage = "Current password is incorrect.";
                            } else {
                                // Hash new password before storing
                                byte[] newHashedBytes = md.digest(newPassword.getBytes("UTF-8"));
                                StringBuilder newHashedPassword = new StringBuilder();
                                for (byte b : newHashedBytes) {
                                    newHashedPassword.append(String.format("%02x", b));
                                }

                                stmt = con.prepareStatement("UPDATE teacher_table SET password = ? WHERE username = ?");
                                stmt.setString(1, newHashedPassword.toString());
                                stmt.setString(2, username);
                                stmt.executeUpdate();
                                successMessage = "Password changed successfully!";
                            }
                        } else {
                            errorMessage = "User not found.";
                        }
                    } catch (SQLException | java.security.NoSuchAlgorithmException e) {
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
                        PreparedStatement stmt = con.prepareStatement("SELECT teacher_id, username, college, department, year_id, semester, course_name FROM teacher_table WHERE username = ?");
                        stmt.setString(1, username);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
            %>
                            <p><span>Teacher ID:</span> <%= rs.getInt("teacher_id") %></p>
                            <p><span>Username:</span> <%= rs.getString("username") %></p>
                            <p><span>College:</span> <%= rs.getString("college") %></p>
                            <p><span>Department:</span> <%= rs.getString("department") %></p>
                            <p><span>Year:</span> <%= rs.getInt("year_id") %></p>
                            <p><span>Semester:</span> <%= rs.getInt("semester") %></p>
                            <p><span>Course Name:</span> <%= rs.getString("course_name") %></p>
            <% 
                        } else { 
            %>
                            <p>No profile data available or you are not a teacher.</p>
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
            <form method="POST" onsubmit="return validatePassword();">
                <input type="password" name="current_password" placeholder="Current Password" required>
                <input type="password" name="new_password" placeholder="New Password" required>
                <input type="password" name="confirm_password" placeholder="Confirm New Password" required>
                <div id="passwordError" class="error"></div> <!-- Error message for password validation -->
                <button type="submit">Change Password</button>
            </form>
        </div>
    </div>
</body>
</html>