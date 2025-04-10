<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Courses</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f9f9f9;
        }
        
        h1 {
            text-align: center;
            color: #333;
        }

        h2 {
            color: #555;
        }

        form {
            margin: 20px 0;
            padding: 15px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        label {
            margin-right: 10px;
            color: #333;
        }

        select {
            margin: 10px 0;
            padding: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: auto;
        }

        button {
            padding: 10px 15px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        button:hover {
            background-color: #0056b3;
        }

        table {
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        th, td {
            padding: 10px;
            text-align: left;
            border: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
            color: #333;
        }

        tbody tr:hover {
            background-color: #f9f9f9;
        }
    </style>
</head>
<body>
    <h1>Available Courses</h1>

    <!-- Form to select year and semester -->
    <form action="student-courses.jsp" method="get">
        <label for="year_id">Select Your Year:</label>
        <select name="year_id" id="year_id" onchange="this.form.submit()" required>
            <option value="">Select Year</option>
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rsYears = null;

                try {
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                    String yearQuery = "SELECT year_id, year_name FROM years";
                    pstmt = conn.prepareStatement(yearQuery);
                    rsYears = pstmt.executeQuery();

                    // Get selected year from request
                    String selectedYearId = request.getParameter("year_id");

                    while (rsYears.next()) {
                        int yearId = rsYears.getInt("year_id");
                        String yearName = rsYears.getString("year_name");
            %>
            <option value="<%= yearId %>" <%= (yearId == (selectedYearId != null ? Integer.parseInt(selectedYearId) : -1) ? "selected" : "") %>><%= yearName %></option>
            <%
                    }
                } catch (SQLException e) {
                    out.println("Database error: " + e.getMessage());
                } finally {
                    try {
                        if (rsYears != null) rsYears.close();
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        out.println("Error closing connection: " + e.getMessage());
                    }
                }
            %>
        </select>

        <label for="semester">Select Semester:</label>
        <select name="semester" id="semester" required>
            <option value="">Select Semester</option>
            <option value="1" <%= (request.getParameter("semester") != null && request.getParameter("semester").equals("1")) ? "selected" : "" %>>1</option>
            <option value="2" <%= (request.getParameter("semester") != null && request.getParameter("semester").equals("2")) ? "selected" : "" %>>2</option>
        </select>

        <button type="submit">Show Courses</button>
    </form>

    <%
        // If a year and semester are selected, display courses for that year and semester
        String selectedYearId = request.getParameter("year_id");
        String selectedSemester = request.getParameter("semester");

        if (selectedYearId != null && !selectedYearId.isEmpty() &&
            selectedSemester != null && !selectedSemester.isEmpty()) {
            
            int yearId = Integer.parseInt(selectedYearId);
            int semester = Integer.parseInt(selectedSemester);
            ResultSet rsCourses = null;

            try {
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                String courseQuery = "SELECT * FROM academic_courses WHERE year_id = ? AND semester = ?";
                pstmt = conn.prepareStatement(courseQuery);
                pstmt.setInt(1, yearId);
                pstmt.setInt(2, semester);
                rsCourses = pstmt.executeQuery();
    %>
    <h2>Courses for Year <%= yearId %>, Semester <%= semester %></h2>
    <table>
        <thead>
            <tr>
                <th>Course ID</th>
                <th>Course Name</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (rsCourses.next()) {
            %>
            <tr>
                <td><%= rsCourses.getInt("course_id") %></td>
                <td><%= rsCourses.getString("course_name") %></td>
            </tr>
            <%
                }
            } catch (SQLException e) {
                out.println("Database error: " + e.getMessage());
            } finally {
                try {
                    if (rsCourses != null) rsCourses.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    out.println("Error closing connection: " + e.getMessage());
                }
            }
            %>
        </tbody>
    </table>
    <%
        } else { // Display all courses if no year or semester is selected
            ResultSet rsAllCourses = null;

            try {
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
                String selectQuery = "SELECT y.year_name, c.course_name, c.semester FROM academic_courses c JOIN years y ON c.year_id = y.year_id";
                pstmt = conn.prepareStatement(selectQuery);
                rsAllCourses = pstmt.executeQuery();
    %>
    <h2>All Available Courses</h2>
    <table>
        <thead>
            <tr>
                <th>Year</th>
                <th>Course</th>
                <th>Semester</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (rsAllCourses.next()) {
                    String year = rsAllCourses.getString("year_name");
                    String course = rsAllCourses.getString("course_name");
                    String semester = rsAllCourses.getString("semester");
            %>
            <tr>
                <td><%= year %></td>
                <td><%= course %></td>
                <td><%= semester %></td>
            </tr>
            <%
                }
            } catch (SQLException e) {
                out.println("Database error: " + e.getMessage());
            } finally {
                try {
                    if (rsAllCourses != null) rsAllCourses.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    out.println("Error closing connection: " + e.getMessage());
                }
            }
        }
        %>
        </tbody>
    </table>
</body>
</html>
