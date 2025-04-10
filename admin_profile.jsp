<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 0;
        }
        .profile-container {
            max-width: 600px;
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
        .profile-info, .edit-profile {
            margin-top: 20px;
        }
        .profile-info p {
            font-size: 18px;
            margin: 10px 0;
        }
        .profile-info p span {
            font-weight: bold;
        }
        .edit-profile input {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .edit-profile button, .change-password button {
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .edit-profile button:hover, .change-password button:hover {
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
        <h1>Admin Profile</h1>

        <% 
            String successMessage = null;
            String errorMessage = null;

            // Handling password change
            if (request.getMethod().equalsIgnoreCase("POST") && request.getParameter("action").equals("change_password")) {
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
                        PreparedStatement stmt = con.prepareStatement("SELECT password FROM admin_table WHERE username = ?");
                        stmt.setString(1, username);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
                            String dbPassword = rs.getString("password");

                            if (!dbPassword.equals(currentPassword)) {
                                errorMessage = "Current password is incorrect.";
                            } else {
                                stmt = con.prepareStatement("UPDATE admin_table SET password = ? WHERE username = ?");
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

            // Handling profile edit
            if (request.getMethod().equalsIgnoreCase("POST") && request.getParameter("action").equals("edit_profile")) {
                String username = (String) session.getAttribute("username");
                String email = request.getParameter("email");
                String department = request.getParameter("department");
                String phone = request.getParameter("phone");

                // Phone number validation
                if (username == null) {
                    errorMessage = "You need to log in to edit your profile.";
                } else if (!phone.matches("09\\d{8}")) {
                    errorMessage = "Phone number must be 10 digits and start with 09.";
                } else {
                    try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql")) {
                        PreparedStatement stmt = con.prepareStatement("UPDATE admin_table SET email = ?, department = ?, phone = ? WHERE username = ?");
                        stmt.setString(1, email);
                        stmt.setString(2, department);
                        stmt.setString(3, phone);
                        stmt.setString(4, username);
                        stmt.executeUpdate();
                        successMessage = "Profile updated successfully!";
                    } catch (SQLException e) {
                        errorMessage = "Error updating profile: " + e.getMessage();
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
                        PreparedStatement stmt = con.prepareStatement("SELECT * FROM admin_table WHERE username = ?");
                        stmt.setString(1, username);
                        ResultSet rs = stmt.executeQuery();

                        if (rs.next()) {
                            int adminId = rs.getInt("admin_id");
                            String name = rs.getString("username");
                            String email = rs.getString("email");
                            String department = rs.getString("department");
                            String phone = rs.getString("phone");
                            Timestamp registeredOn = rs.getTimestamp("registered_on");
            %>
                            <p><span>Admin ID:</span> <%= adminId %></p>
                            <p><span>Username:</span> <%= name %></p>
                            <p><span>Email:</span> <%= email %></p>
                            <p><span>Department:</span> <%= department %></p>
                            <p><span>Phone:</span> <%= phone %></p>
                            <p><span>Registered On:</span> <%= registeredOn != null ? registeredOn.toString() : "N/A" %></p>
                            <form method="POST" class="edit-profile">
                                <h2>Edit Profile</h2>
                                <input type="hidden" name="action" value="edit_profile">
                                <input type="text" name="email" value="<%= email %>" placeholder="Email" required>
                                <input type="text" name="department" value="<%= department %>" placeholder="Department" required>
                                <input type="text" name="phone" value="<%= phone %>" placeholder="Phone" required>
                                <button type="submit">Update Profile</button>
                            </form>
            <% 
                        } else { 
            %>
                            <p>No profile data available or you are not an admin.</p>
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
                <input type="hidden" name="action" value="change_password">
                <input type="password" name="current_password" placeholder="Current Password" required>
                <input type="password" name="new_password" placeholder="New Password" required>
                <input type="password" name="confirm_password" placeholder="Confirm New Password" required>
                <button type="submit">Change Password</button>
            </form>
        </div>
    </div>
    <div style="text-align: center; margin-top: 20px;">
        <button onclick="window.history.back()" 
                style="padding: 10px 20px; background-color: #6c757d; color: white; border: none; border-radius: 5px; cursor: pointer;">
            Back
        </button>
    </div>
</body>
</html>
