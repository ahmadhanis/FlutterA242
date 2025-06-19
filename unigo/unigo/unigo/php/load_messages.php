<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );

include_once( 'dbconnect.php' );

if ( !isset( $_POST[ 'user_id' ] ) ) {
    echo json_encode( [ 'status' => 'failed', 'message' => 'Missing user_id' ] );
    die();
}

$user_id = $_POST[ 'user_id' ];

$sql = "SELECT 
            m.message_id,
            m.sender_id,
            m.receiver_id,
            m.message,
            m.sent_time,
            m.is_read,
            u.user_name AS sender_name
        FROM tbl_messages m
        JOIN tbl_users u ON m.sender_id = u.user_id
        WHERE m.receiver_id = ?
        ORDER BY m.sent_time DESC";

$stmt = $conn->prepare( $sql );
$stmt->bind_param( 's', $user_id );
$stmt->execute();
$result = $stmt->get_result();

if ( $result->num_rows > 0 ) {
    $messages = [];
    while ( $row = $result->fetch_assoc() ) {
        $messages[] = [
            'message_id' => $row[ 'message_id' ],
            'sender_id' => $row[ 'sender_id' ],
            'receiver_id' => $row[ 'receiver_id' ],
            'message' => $row[ 'message' ],
            'sent_time' => $row[ 'sent_time' ],
            'is_read' => $row[ 'is_read' ],
            'sender_name' => $row[ 'sender_name' ]
        ];
    }
    echo json_encode( [ 'status' => 'success', 'messages' => $messages ] );
} else {
    echo json_encode( [ 'status' => 'success', 'messages' => [] ] );
}

$stmt->close();
$conn->close();
?>