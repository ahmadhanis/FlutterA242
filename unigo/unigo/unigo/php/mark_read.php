<?php
error_reporting( E_ALL );
ini_set( 'display_errors', 1 );
header( 'Access-Control-Allow-Origin: *' );
header( 'Content-Type: application/json' );

include_once( 'dbconnect.php' );

if ( $_SERVER[ 'REQUEST_METHOD' ] === 'POST' ) {
    $messageId = $_POST[ 'message_id' ] ?? '';

    if ( empty( $messageId ) ) {
        echo json_encode( [ 'status' => 'failed', 'message' => 'Missing message_id' ] );
        exit();
    }

    $stmt = $conn->prepare( 'UPDATE tbl_messages SET is_read = 1 WHERE message_id = ?' );
    if ( $stmt ) {
        $stmt->bind_param( 'i', $messageId );
        if ( $stmt->execute() ) {
            echo json_encode( [ 'status' => 'success', 'message' => 'Message marked as read' ] );
        } else {
            echo json_encode( [ 'status' => 'failed', 'message' => 'Execution failed' ] );
        }
        $stmt->close();
    } else {
        echo json_encode( [ 'status' => 'failed', 'message' => 'Prepare failed' ] );
    }
} else {
    echo json_encode( [ 'status' => 'failed', 'message' => 'Invalid request method' ] );
}
?>
