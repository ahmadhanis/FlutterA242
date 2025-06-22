<?php
include_once('dbconnect.php');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $userId = $_POST['user_id'] ?? '';

    if (empty($userId)) {
        sendJsonResponse(['status' => 'failed', 'message' => 'User ID is required.']);
        exit();
    }

    $sql = "SELECT 
                m1.message_id, m1.sender_id, m1.receiver_id, m1.message, 
                m1.attachment_url, m1.reply_to, m1.sent_time, m1.is_read,
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

    $stmt = $conn->prepare($sql);
    $stmt->bind_param('ii', $userId, $userId);
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
        $sender_name,
        $receiver_name
    );

    $messages = [];
    while ($stmt->fetch()) {
        $messages[] = [
            'message_id'      => $message_id,
            'sender_id'       => $sender_id,
            'receiver_id'     => $receiver_id,
            'message'         => $message,
            'attachment_url'  => $attachment_url,
            'reply_to'        => $reply_to,
            'sent_time'       => $sent_time,
            'is_read'         => $is_read,
            'sender_name'     => $sender_name,
            'receiver_name'   => $receiver_name
        ];
    }

    sendJsonResponse(['status' => 'success', 'messages' => $messages]);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Invalid request method.']);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
    exit();
}
