<?php
include_once( 'dbconnect.php' );

if ( $_SERVER[ 'REQUEST_METHOD' ] === 'POST' ) {
    $userId = $_POST[ 'user_id' ] ?? '';

    if ( empty( $userId ) ) {
        sendJsonResponse( [ 'status' => 'failed', 'message' => 'User ID is required.' ] );
        exit();
    }

    $sql = "SELECT 
                m1.*, 
                sender.user_name AS sender_name,
                receiver.user_name AS receiver_name
            FROM tbl_messages m1
            JOIN (
                SELECT 
                    LEAST(sender_id, receiver_id) AS user1,
                    GREATEST(sender_id, receiver_id) AS user2,
                    MAX(message_id) AS max_id
                FROM tbl_messages
                WHERE sender_id = ? OR receiver_id = ?
                GROUP BY user1, user2
            ) latest ON m1.message_id = latest.max_id
            JOIN tbl_users sender ON sender.user_id = m1.sender_id
            JOIN tbl_users receiver ON receiver.user_id = m1.receiver_id
            ORDER BY m1.sent_time DESC";

    $stmt = $conn->prepare( $sql );
    $stmt->bind_param( 'ii', $userId, $userId );
    $stmt->execute();
    $result = $stmt->get_result();

    $messages = [];
    while ( $row = $result->fetch_assoc() ) {
        $messages[] = $row;
    }

    sendJsonResponse( [ 'status' => 'success', 'messages' => $messages ] );
} else {
    sendJsonResponse( [ 'status' => 'failed', 'message' => 'Invalid request method.' ] );
}

function sendJsonResponse( $sentArray )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $sentArray );
    exit();
}
?>
