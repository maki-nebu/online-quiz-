<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CSV File Upload</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        h2 {
            text-align: center;
           background-color: #333;
            margin-top: 20px;
            color:white;
        }
        form {
            max-width: 400px;
            margin: 30px auto;
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
        input[type="file"] {
            margin-bottom: 15px;
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
    <h2>Upload CSV File</h2>
    <form action="uploadCsv" method="post" enctype="multipart/form-data">
        <label for="csvFile">Choose CSV file to upload:</label>
        <input type="file" name="csvFile" id="csvFile" required />
        <button type="submit">Upload</button>
    </form>
</body>
</html>