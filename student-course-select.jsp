<%@ page import="java.sql.*, javax.servlet.http.*, java.util.List, java.util.ArrayList" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Select Course</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
            text-align: center;
        }
        form {
            max-width: 400px;
            margin: 0 auto;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        label {
            display: block;
            margin-bottom: 10px;
            font-weight: bold;
        }
        select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        button {
            background-color: #333;
            color: white;
            padding: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>

<%
    HttpSession userSession = request.getSession();
    String username = (String) userSession.getAttribute("username");

    if (username == null) {
        out.println("No user is logged in.");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");

        // Query the student_table for year and semester based on username
        String studentQuery = "SELECT year_id, semester FROM student_table WHERE username = ?";
        pstmt = conn.prepareStatement(studentQuery);
        pstmt.setString(1, username);
        rs = pstmt.executeQuery();

        String studentYear = null;
        String studentSemester = null;

        if (rs.next()) {
            studentYear = rs.getString("year_id");
            studentSemester = rs.getString("semester");
        } else {
            out.println("No student found with the username: " + username);
            return;
        }

        rs.close();
        pstmt.close();

        // Query academic_courses to fetch courses based on year and semester
        String courseQuery = "SELECT course_id, course_name FROM academic_courses WHERE year_id = ? AND semester = ?";
        pstmt = conn.prepareStatement(courseQuery);
        pstmt.setString(1, studentYear);
        pstmt.setString(2, studentSemester);
        rs = pstmt.executeQuery();

        List<String> courses = new ArrayList<>();
        while (rs.next()) {
            courses.add(rs.getString("course_name"));
        }

%>
    <h1>Select Course for Year <%= studentYear %>, Semester <%= studentSemester %></h1>
    <form method="post" action="course-details.jsp">
        <label for="courses">Select Course:</label>
        <select id="courses" name="course_name" required>
            <option value="">-- Select a Course --</option> <!-- Default placeholder option -->
            <%
                if (courses.isEmpty()) {
                    out.println("<option value=''>No courses available</option>");
                } else {
                    for (String course : courses) {
                        out.println("<option value='" + course + "'>" + course + "</option>");
                    }
                }
            %>
        </select>
        <button type="submit">Proceed to Course Details</button>
    </form>

<%
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h2 style='color: red;'>Database error: " + e.getMessage() + "</h2>");
    } finally {
        // Clean up resources
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>

</body>
</html>