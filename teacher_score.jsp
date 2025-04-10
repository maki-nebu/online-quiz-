<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Teacher View Scores</title>
</head>
<body>

<%
    String courseIdStr = request.getParameter("course_id");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    if (courseIdStr == null || courseIdStr.isEmpty()) {
        out.println("<h2 style='color: red;'>Course ID is missing.</h2>");
        return;
    }

    int courseId = Integer.parseInt(courseIdStr);

    try {
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3305/System_exam", "root", "mysql");
        String query = "SELECT s.student_id, s.student_name, r.score FROM results r JOIN students s ON r.student_id = s.student_id WHERE r.course_id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, courseId);
        rs = pstmt.executeQuery();

        if (!rs.isBeforeFirst()) {
            out.println("<h2>No results found for this course.</h2>");
        } else {
%>
            <h1>Scores for Course ID: <%= courseId %></h1>
            <table border="1">
                <tr>
                    <th>Student ID</th>
                    <th>Student Name</th>
                    <th>Score</th>
                </tr>
                <%
                while (rs.next()) {
                    int studentId = rs.getInt("student_id");
                    String studentName = rs.getString("student_name");
                    int score = rs.getInt("score");
                %>
                    <tr>
                        <td><%= studentId %></td>
                        <td><%= studentName %></td>
                        <td><%= score %></td>
                    </tr>
                <%
                }
                %>
            </table>
<%
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<h2 style='color: red;'>Database error: " + e.getMessage() + "</h2>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>

</body>
</html>