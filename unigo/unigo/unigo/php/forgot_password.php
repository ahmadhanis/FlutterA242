<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
header( 'Content-Type: application/json' );

include_once( 'dbconnect.php' );

// PHPMailer
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require '/home4/slumber6/PHPMailer/src/Exception.php';
require '/home4/slumber6/PHPMailer/src/PHPMailer.php';
require '/home4/slumber6/PHPMailer/src/SMTP.php';

function generateOTP( $length = 6 ) {
    return str_pad( mt_rand( 0, pow( 10, $length ) - 1 ), $length, '0', STR_PAD_LEFT );
}

function sendEmail( $email, $otp ) {
    $mail = new PHPMailer( true );
    try {
        $mail->isSMTP();
        $mail->Host = 'your_smtp_host';
        $mail->SMTPAuth = true;
        $mail->Username = 'your_smtp_username';
        $mail->Password = 'your_smtp_password';
        // Replace with real password
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $mail->Port = 465;

        $mail->setFrom( 'your_smtp_email', 'Unigo Support' );
        $mail->addAddress( $email );
        $mail->isHTML( true );
        $mail->Subject = 'Reset Your Password - Unigo App';
        $mail->Body = "
                <!DOCTYPE html>
                <html lang='en'>
                <head>
                  <meta charset='UTF-8'>
                  <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                  <style>
                    @media only screen and (max-width: 600px) {
                      .container {
                        padding: 16px !important;
                      }
                      .button {
                        width: 100% !important;
                        display: block !important;
                      }
                    }
                  </style>
                </head>
                <body style='margin:0; padding:0; font-family: Arial, sans-serif; background-color: #f9f9f9;'>
                  <div class='container' style='max-width: 600px; margin: auto; background-color: #ffffff; border-radius: 10px; padding: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);'>
                
                    <h2 style='color: #2d2d2d; margin-bottom: 8px;'>🔐 Password Reset Request</h2>
                    <p style='color: #555; line-height: 1.6;'>Hello,</p>
                    <p style='color: #555; line-height: 1.6;'>
                      We received a request to reset the password associated with your <strong>Unigo</strong> account.
                      If you made this request, please click the button below to reset your password:
                    </p>
                
                    <p style='text-align: center; margin: 32px 0;'>
                      <a class='button' href='https://slumberjer.com/unigo/php/reset_password.php?email=$email&otp=$otp' 
                         style='background-color: #6a1b9a; color: #fff; padding: 14px 28px; border-radius: 5px; text-decoration: none; font-weight: bold;'>
                         Reset Password
                      </a>
                    </p>
                
                    <p style='color: #555; line-height: 1.6;'>
                      This link will expire in 30 minutes or after it's used once. If you did not request a password reset, no further action is required.
                    </p>
                
                    <hr style='margin: 32px 0; border: none; border-top: 1px solid #eee;'>
                
                    <p style='font-size: 12px; color: #888888;'>
                      You received this email because you signed up for the Unigo app. If you believe this is a mistake, please ignore it.
                    </p>
                    <p style='font-size: 12px; color: #888888;'>Unigo © 2025. All rights reserved.</p>
                  </div>
                </body>
                </html>
                ";

        $mail->send();
    } catch ( Exception $e ) {
        // Optionally log or return $mail->ErrorInfo
    }
}

if ( $_SERVER[ 'REQUEST_METHOD' ] === 'POST' && isset( $_POST[ 'email' ] ) ) {
    $email = trim( $_POST[ 'email' ] );
    $stmt = $conn->prepare( 'SELECT user_id FROM tbl_users WHERE user_email = ?' );
    $stmt->bind_param( 's', $email );
    $stmt->execute();
    $stmt->store_result();

    if ( $stmt->num_rows > 0 ) {
        // Generate and update OTP
        $otp = generateOTP();
        $now = date( 'Y-m-d H:i:s' );

        $update = $conn->prepare( 'UPDATE tbl_users SET otp = ?, otp_generated_at = ? WHERE user_email = ?' );
        $update->bind_param( 'sss', $otp, $now, $email );
        $update->execute();

        sendEmail( $email, $otp );
        echo json_encode( [ 'status' => 'success', 'message' => 'Reset link sent to your email.' ] );
    } else {
        echo json_encode( [ 'status' => 'error', 'message' => 'Email not found.' ] );
    }
} else {
    echo json_encode( [ 'status' => 'error', 'message' => 'Invalid request.' ] );
}
?>
