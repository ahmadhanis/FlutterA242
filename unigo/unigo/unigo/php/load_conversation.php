<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

include_once('dbconnect.php');

$userId = $_POST['user_id'] ?? '';
$partnerId = $_POST['partner_id'] ?? '';

if (empty($userId) || empty($partnerId)) {
    echo json_encode([
        'status' => 'failed',
        'message' => 'Missing user ID or partner ID'
    ]);
    exit();
}

$sql = "SELECT m.message_id, m.sender_id, m.receiver_id, m.message, 
               m.attachment_url, m.reply_to, m.sent_time, m.is_read,
               u.user_name AS sender_name
        FROM tbl_messages m
        JOIN tbl_users u ON m.sender_id = u.user_id
        WHERE (m.sender_id = ? AND m.receiver_id = ?)
           OR (m.sender_id = ? AND m.receiver_id = ?)
        ORDER BY m.sent_time ASC";

$stmt = $conn->prepare($sql);
$stmt->bind_param('iiii', $userId, $partnerId, $partnerId, $userId);
$stmt->execute();
$stmt->store_result();

$stmt->bind_result(
    $message_id,
    $sender_id,
    $receiver_id,
    $message,
    $attachment_url,
    $reply_to,
    $sent_time,
    $is_read,
    $sender_name
);

$messages = [];
while ($stmt->fetch()) {
    $messages[] = [
        'message_id'     => $message_id,
        'sender_id'      => $sender_id,
        'receiver_id'    => $receiver_id,
        'message'        => $message,
        'attachment_url' => $attachment_url,
        'reply_to'       => $reply_to,
        'sent_time'      => $sent_time,
        'is_read'        => $is_read,
        'sender_name'    => $sender_name
    ];
}

echo json_encode([
    'status' => 'success',
    'messages' => $messages
]);
?>
