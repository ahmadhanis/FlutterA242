<?php
include_once( 'dbconnect.php' );

if ( $_SERVER[ 'REQUEST_METHOD' ] === 'POST' ) {
    $messageId = $_POST[ 'message_id' ] ?? '';

    if ( empty( $messageId ) ) {
        sendJsonResponse( [ 'status' => 'failed', 'message' => 'Message ID is required.' ] );
        exit();
    }

    $sql = 'DELETE FROM tbl_messages WHERE message_id = ?';
    $stmt = $conn->prepare( $sql );
    $stmt->bind_param( 'i', $messageId );

    if ( $stmt->execute() ) {
        if ( $stmt->affected_rows > 0 ) {
            sendJsonResponse( [ 'status' => 'success', 'message' => 'Message deleted successfully.' ] );
        } else {
            sendJsonResponse( [ 'status' => 'failed', 'message' => 'No message found with that ID.' ] );
        }
    } else {
        sendJsonResponse( [ 'status' => 'failed', 'message' => 'Database error.' ] );
    }

    $stmt->close();
    $conn->close();
} else {
    sendJsonResponse( [ 'status' => 'failed', 'message' => 'Invalid request method.' ] );
}

function sendJsonResponse( $array )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $array );
    exit();
}
?>
