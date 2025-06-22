<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );

if ( !isset( $_POST ) ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

include_once( 'dbconnect.php' );
require '/home4/slumber6/PHPMailer/src/Exception.php';
require '/home4/slumber6/PHPMailer/src/PHPMailer.php';
require '/home4/slumber6/PHPMailer/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$name = $_POST[ 'name' ];
$email = $_POST[ 'email' ];
$plainPassword = $_POST[ 'password' ];
// For sending email
$password = sha1( $plainPassword );
// For storage
$phone = $_POST[ 'phone' ];
$university = $_POST[ 'university' ];
$address = $_POST[ 'address' ];
$image = base64_decode( $_POST[ 'image' ] );

$sqlinsert = "INSERT INTO `tbl_users`(`user_name`, `user_email`, `user_password`, `user_phone`, `user_university`, `user_address`) 
              VALUES ('$name','$email','$password','$phone','$university','$address')";

try {
    if ( $conn->query( $sqlinsert ) === TRUE ) {
        $last_id = $conn->insert_id;
        $path = '../assets/images/profiles/' . $last_id . '.png';
        file_put_contents( $path, $image );

        sendEmail( $email, $name, $plainPassword );
        // Send email confirmation

        $response = array( 'status' => 'success', 'data' => null );
        sendJsonResponse( $response );
    } else {
        $response = array( 'status' => 'failed', 'data' => null );
        sendJsonResponse( $response );
    }
} catch ( Exception $e ) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

function sendEmail( $email, $name, $password )
 {
    $mail = new PHPMailer( true );
    try {
        $mail->isSMTP();
        $mail->Host = 'your_smtp_host';
        $mail->SMTPAuth = true;
        $mail->Username = 'your_smtp_username';
        $mail->Password = 'your_email_password';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $mail->Port = 465;

        $mail->setFrom( 'your_smtp_email', 'UniGo Admin' );
        $mail->addAddress( $email );
        $mail->isHTML( true );
        $mail->Subject = 'Welcome to UniGo - Registration Successful';
        $mail->Body = "
<div style='font-family: Arial, sans-serif; padding: 24px; background-color: #f4f6f8; border-radius: 12px; max-width: 600px; margin: auto;'>
    <div style='background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);'>
        <h2 style='color: #6a1b9a; margin-bottom: 16px;'>Welcome to UniGo, $name!</h2>
        <p style='font-size: 16px; color: #333;'>Thank you for registering with <strong>UniGo</strong>. Below are your account details:</p>

        <table style='width: 100%; margin-top: 20px; margin-bottom: 20px; font-size: 15px;'>
            <tr>
                <td style='padding: 8px 0;'><strong>Email:</strong></td>
                <td>$email</td>
            </tr>
            <tr>
                <td style='padding: 8px 0;'><strong>Password:</strong></td>
                <td>$password</td>
            </tr>
        </table>
        <br>

        <p style='font-size: 14px; color: #555;'>Please keep this email for your records. If you did not register for UniGo, please contact our support team immediately.</p>
        
        <hr style='margin: 30px 0; border: none; border-top: 1px solid #ddd;' />
        
        <p style='font-size: 13px; color: #999;'>This is an automated message. Please do not reply directly to this email.</p>
    </div>
    <div style='text-align: center; font-size: 12px; color: #999; margin-top: 16px;'>
        &copy; " . date( 'Y' ) . " UniGo by Slumberjer. All rights reserved.
    </div>
</div>
";

        $mail->send();
    } catch ( Exception $e ) {
        // Email sending failed but don't block registration
    }
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json' );
        echo json_encode( $sentArray );
    }
    ?>
