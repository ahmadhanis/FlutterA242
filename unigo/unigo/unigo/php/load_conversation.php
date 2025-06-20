<?php
error_reporting( E_ALL );
ini_set( 'display_errors', 1 );
header( 'Access-Control-Allow-Origin: *' );
header( 'Content-Type: application/json' );

include_once( 'dbconnect.php' );

$userId = $_POST[ 'user_id' ] ?? '';
$partnerId = $_POST[ 'partner_id' ] ?? '';

if ( empty( $userId ) || empty( $partnerId ) ) {
    echo json_encode( [ 'status' => 'failed', 'message' => 'Missing user ID or partner ID' ] );
    exit();
}

$sql = "SELECT m.*, u.user_name AS sender_name 
        FROM tbl_messages m
        JOIN tbl_users u ON m.sender_id = u.user_id
        WHERE (m.sender_id = ? AND m.receiver_id = ?)
           OR (m.sender_id = ? AND m.receiver_id = ?)
        ORDER BY m.sent_time ASC";

$stmt = $conn->prepare( $sql );
$stmt->bind_param( 'iiii', $userId, $partnerId, $partnerId, $userId );
$stmt->execute();
$result = $stmt->get_result();

$messages = [];
while ( $row = $result->fetch_assoc() ) {
    $messages[] = $row;
}

echo json_encode( [
    'status' => 'success',
    'messages' => $messages
] );
?>
