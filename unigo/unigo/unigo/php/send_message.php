<?php
error_reporting( E_ALL );
ini_set( 'display_errors', 1 );
header( 'Access-Control-Allow-Origin: *' );

include_once( 'dbconnect.php' );

if ( $_SERVER[ 'REQUEST_METHOD' ] === 'POST' ) {
    $senderId = $_POST[ 'sender_id' ] ?? '';
    $receiverId = $_POST[ 'receiver_id' ] ?? '';
    $messageContent = $_POST[ 'message_content' ] ?? '';
    $productId = $_POST[ 'product_id' ] ?? null;
    $productName = $_POST[ 'product_name' ] ?? null;
    $messageContent = "$productName\n\n$messageContent";
    if ( empty( $senderId ) || empty( $receiverId ) || empty( $messageContent ) ) {
        sendJsonResponse( [ 'status' => 'failed', 'message' => 'Missing required fields' ] );
        exit();
    }

    $stmt = $conn->prepare( 'INSERT INTO tbl_messages (sender_id, receiver_id, message) VALUES (?, ?, ?)' );
    if ( !$stmt ) {
        sendJsonResponse( [
            'status' => 'failed',
            'error' => $conn->error,
            'message' => 'Prepare failed'
        ] );
        exit();
    }
    $stmt->bind_param( 'iis', $senderId, $receiverId, $messageContent );

    if ( $stmt->execute() ) {
        sendJsonResponse( [ 'status' => 'success', 'message' => 'Message sent' ] );
    } else {
        sendJsonResponse( [ 'status' => 'failed', 'message' => 'Failed to send message' ] );
    }

    $stmt->close();
} else {
    sendJsonResponse( [ 'status' => 'failed', 'message' => 'Invalid request method' ] );
}

function sendJsonResponse( $sentArray )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $sentArray );
}

?>