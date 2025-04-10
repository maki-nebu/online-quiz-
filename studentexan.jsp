<%@ page import="java.sql.Connection, java.sql.DriverManager, java.sql.ResultSet, java.sql.SQLException, java.sql.Statement, java.sql.PreparedStatement" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Examination</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f4;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 10px;
            border: 1px solid #ccc;
            text-align: left;
        }
        th {
            background-color: #28a745;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        form {
            margin-bottom: 20px;
        }
        input[type="text"] {
            padding: 10px;
            width: 300px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            padding: 10px 20px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <h1>Student Examination Data</h1>
    
    <!-- Exam Code Form -->
    <form method="post">
        <label for="exam_code">Enter Exam Code:</label>
        <input type="text" id="exam_code" name="exam_code" required>
        <button type="submit">Start Exam</button>
    </form>

    <!-- Table to Display Student Info -->
    <table>
        <thead>
            <tr>
                <th>Student ID</th>
                <th>Username</th>
                <th>Password</th>
                <th>Year</th>
                <th>Semester</th>
                <th>College</th>
                <th>Department</th>
            </tr>
        </thead>
        <tbody>
            <%
                Connection con = null;
                Statement stmt = null;
                ResultSet rs = null;
                PreparedStatement insertStmt = null;

                try {
                    // Load MySQL driver
                    Class.forName("com.mysql.cj.jdbc.Driver");

                    // Establish connection
                    con = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

                    // Fetch student details
                    stmt = con.createStatement();
                    String sql = "SELECT student_id, username, password, year_id, semester, college, department " +
                                 "FROM student_table";
                    rs = stmt.executeQuery(sql);

                    // If form is submitted (exam code entered)
                    if (request.getMethod().equalsIgnoreCase("POST")) {
                        String examCode = request.getParameter("exam_code");
                        // Insert attendance details for the student
                        String insertSql = "INSERT INTO attendance (student_id, exam_code, exam_status, year_id, semester) " +
                                           "VALUES (?, ?, 'started', ?, ?)";
                        insertStmt = con.prepareStatement(insertSql);

                        while (rs.next()) {
                            // Get student details
                            String studentId = rs.getString("student_id");
                            String username = rs.getString("username");
                            String password = rs.getString("password");
                            String yearId = rs.getString("year_id");
                            String semester = rs.getString("semester");
                            String college = rs.getString("college");
                            String department = rs.getString("department");

                            // Insert student attendance into the table
                            insertStmt.setString(1, studentId);
                            insertStmt.setString(2, examCode);
                            insertStmt.setString(3, yearId);
                            insertStmt.setString(4, semester);
                            insertStmt.executeUpdate();
            %>
            <tr>
                <td><%= studentId %></td>
                <td><%= username %></td>
                <td><%= password %></td>
                <td><%= yearId %></td>
                <td><%= semester %></td>
                <td><%= college %></td>
                <td><%= department %></td>
            </tr>
            <%
                        }
                    }
                } catch (SQLException e) {
                    out.println("<tr><td colspan='7'>Error fetching/inserting data: " + e.getMessage() + "</td></tr>");
                } catch (ClassNotFoundException e) {
                    out.println("<tr><td colspan='7'>Error loading database driver: " + e.getMessage() + "</td></tr>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (insertStmt != null) try { insertStmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (con != null) try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            %>
        </tbody>
    </table>
</body>
</html>
