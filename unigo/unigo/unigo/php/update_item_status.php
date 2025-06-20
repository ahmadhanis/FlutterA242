<?php
error_reporting( E_ALL );
ini_set( 'display_errors', 1 );
header( 'Access-Control-Allow-Origin: *' );
header( 'Content-Type: application/json' );

include_once( 'dbconnect.php' );

if ( $_SERVER[ 'REQUEST_METHOD' ] === 'POST' ) {
    $itemId = $_POST[ 'item_id' ] ?? '';
    $newStatus = $_POST[ 'item_status' ] ?? '';

    if ( empty( $itemId ) || empty( $newStatus ) ) {
        sendJsonResponse( [
            'status' => 'failed',
            'message' => 'Missing item_id or item_status'
        ] );
        exit();
    }

    $stmt = $conn->prepare( 'UPDATE tbl_items SET item_status = ? WHERE item_id = ?' );
    if ( !$stmt ) {
        sendJsonResponse( [
            'status' => 'failed',
            'message' => 'Prepare failed',
            'error' => $conn->error
        ] );
        exit();
    }

    $stmt->bind_param( 'si', $newStatus, $itemId );

    if ( $stmt->execute() ) {
        sendJsonResponse( [
            'status' => 'success',
            'message' => 'Item status updated successfully'
        ] );
    } else {
        sendJsonResponse( [
            'status' => 'failed',
            'message' => 'Failed to update item status',
            'error' => $stmt->error
        ] );
    }

    $stmt->close();
    $conn->close();
} else {
    sendJsonResponse( [
        'status' => 'failed',
        'message' => 'Invalid request method'
    ] );
}

function sendJsonResponse( $response )
 {
    echo json_encode( $response );
}
?>
