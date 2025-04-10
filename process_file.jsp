<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*, java.sql.*, jakarta.servlet.http.Part, java.util.*" %>
<%@ page isErrorPage="false" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page directive.page="javax.servlet.annotation.MultipartConfig" %>

<%
    response.setContentType("text/html;charset=UTF-8");

    // Variables for database connection
    String dbURL = "jdbc:mysql://localhost:3305/System";
    String dbUser = "your_username";
    String dbPassword = "your_password";

    // Directory to save uploaded files
    String uploadDir = application.getRealPath("") + File.separator + "uploads";
    File uploadDirectory = new File(uploadDir);
    if (!uploadDirectory.exists()) {
        uploadDirectory.mkdir(); // Create directory if not exists
    }

    String fileName = null;
    String savePath = null;
    boolean isFileUploaded = false;

    try {
        // Ensure the request is multipart
        if (request.getContentType() != null && request.getContentType().startsWith("multipart/form-data")) {
            Collection<Part> parts = request.getParts(); // Process uploaded parts
            for (Part part : parts) {
                if ("file".equals(part.getName())) { // Check for the file input
                    fileName = part.getSubmittedFileName();
                    if (fileName != null && !fileName.isEmpty()) {
                        savePath = uploadDir + File.separator + fileName;
                        part.write(savePath); // Save file to the directory
                        isFileUploaded = true;
                    }
                }
            }

            // Check if the file was uploaded
            if (isFileUploaded) {
                // Example: Insert data into database (e.g., related to the file or content)
                String questionText = "Sample Question"; // Replace with your logic
                String questionType = "MCQ"; // Replace with your logic
                String option1 = "Option 1"; // Replace with your logic
                String option2 = "Option 2"; // Replace with your logic
                String option3 = "Option 3"; // Replace with your logic
                String option4 = "Option 4"; // Replace with your logic
                String correctOption = "Option 1"; // Replace with your logic
                String correctAnswer = "Correct Answer"; // Replace with your logic
                int courseId = 101; // Replace with your logic

                // Establish database connection
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);

                // Insert uploaded file's data and additional information into the database
                String sql = "INSERT INTO questions (course_id, question_text, question_type, option_1, option_2, option_3, option_4, correct_option, correct_answer) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, courseId);
                stmt.setString(2, questionText);
                stmt.setString(3, questionType);
                stmt.setString(4, option1);
                stmt.setString(5, option2);
                stmt.setString(6, option3);
                stmt.setString(7, option4);
                stmt.setString(8, correctOption);
                stmt.setString(9, correctAnswer);

                int rowsInserted = stmt.executeUpdate();
                if (rowsInserted > 0) {
                    out.println("<h3>File uploaded successfully and data inserted into the database.</h3>");
                } else {
                    out.println("<h3>File uploaded but database insertion failed.</h3>");
                }

                // Close database resources
                stmt.close();
                conn.close();
            } else {
                out.println("<h3>No file uploaded.</h3>");
            }
        } else {
            out.println("<h3>Invalid request type.</h3>");
        }
    } catch (Exception e) {
        e.printStackTrace(out);
        out.println("<h3>Error: " + e.getMessage() + "</h3>");
    }
%>

