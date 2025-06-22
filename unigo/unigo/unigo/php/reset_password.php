<?php
error_reporting(0);
include_once("dbconnect.php");

function showMessage($message, $success = false) {
    echo "
    <div class='container'>
        <div class='message " . ($success ? "success" : "error") . "'>
            $message
        </div>
    </div>";
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['email']) && isset($_GET['otp'])) {
    $email = $_GET['email'];
    $otp = $_GET['otp'];

    $stmt = $conn->prepare("SELECT user_id FROM tbl_users WHERE user_email = ? AND otp = ?");
    $stmt->bind_param("ss", $email, $otp);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows !== 1) {
        showMessage("Invalid or expired password reset link.");
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $otp = $_POST['otp'];
    $password = $_POST['new_password'];
    $confirm = $_POST['confirm_password'];

    if ($password !== $confirm) {
        showMessage("Passwords do not match.");
    }

    $hashed = sha1($password);
    $stmt = $conn->prepare("UPDATE tbl_users SET user_password = ?, otp = NULL WHERE user_email = ? AND otp = ?");
    $stmt->bind_param("sss", $hashed, $email, $otp);

    if ($stmt->execute() && $stmt->affected_rows > 0) {
        showMessage("Password has been successfully reset.", true);
    } else {
        showMessage("Failed to reset password. Please try again.");
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Reset Password</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(to bottom right, #6a1b9a, #8e24aa);
            color: #333;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 420px;
            margin: 80px auto;
            background: #fff;
            padding: 25px 30px;
            border-radius: 12px;
            box-shadow: 0 0 10px rgba(0,0,0,0.15);
        }
        h2 {
            text-align: center;
            margin-bottom: 25px;
            color: #6a1b9a;
        }
        input[type="password"], input[type="submit"] {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 16px;
        }
        input[type="submit"] {
            background: #6a1b9a;
            color: #fff;
            cursor: pointer;
            transition: 0.3s ease;
        }
        input[type="submit"]:hover {
            background: #8e24aa;
        }
        .message {
            padding: 15px;
            margin-top: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .message.success {
            background-color: #e0f2f1;
            color: #00695c;
        }
        .message.error {
            background-color: #ffebee;
            color: #c62828;
        }
        @media (max-width: 480px) {
            .container {
                margin: 40px 16px;
                padding: 20px;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Reset Your Password</h2>
    <form method="POST">
        <input type="hidden" name="email" value="<?= htmlspecialchars($_GET['email']) ?>">
        <input type="hidden" name="otp" value="<?= htmlspecialchars($_GET['otp']) ?>">

        <input type="password" name="new_password" placeholder="New Password" required>
        <input type="password" name="confirm_password" placeholder="Confirm Password" required>

        <input type="submit" value="Reset Password">
    </form>
</div>

</body>
</html>
