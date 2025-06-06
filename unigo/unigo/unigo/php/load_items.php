<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
// running as crome app
include_once( 'dbconnect.php' );

if ( isset( $_GET[ 'userid' ] ) ) {
    $userid = $_GET[ 'userid' ];
    $sqlloaditems = "SELECT 
    i.item_id, 
    i.item_name, 
    i.item_desc, 
    i.item_status, 
    i.item_price, 
    i.item_qty, 
    i.item_delivery, 
    i.item_date, 
    i.user_id,
    u.user_name, 
    u.user_phone, 
    u.user_email 
FROM tbl_items i
JOIN tbl_users u ON i.user_id = u.user_id WHERE i.user_id = '$userid'
ORDER BY i.item_date DESC";

} else {
    $sqlloaditems = "SELECT 
    i.item_id, 
    i.item_name, 
    i.item_desc, 
    i.item_status, 
    i.item_price, 
    i.item_qty, 
    i.item_delivery, 
    i.item_date, 
    i.user_id,
    u.user_name, 
    u.user_phone, 
    u.user_email 
FROM tbl_items i
JOIN tbl_users u ON i.user_id = u.user_id
ORDER BY i.item_date DESC";
}

//echo $sqlloaditems;
$result = $conn->query( $sqlloaditems );
if ( $result->num_rows > 0 ) {
    $sentArray = array();
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;
    }
    $response = array( 'status' => 'success', 'data' => $sentArray );
    sendJsonResponse( $response );
} else {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
}

function sendJsonResponse( $sentArray )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $sentArray );
}

?>
