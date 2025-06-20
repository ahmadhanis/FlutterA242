<?php
error_reporting( 0 );
header( 'Access-Control-Allow-Origin: *' );
// running as crome app
include_once( 'dbconnect.php' );

$search = $_GET[ 'search' ] ?? '';
$userid = $_GET[ 'userid' ] ?? null;

$number_of_result = 0;
$numberofresult = 0;
//step 1
$results_per_page = 10;
//step 2
if ( isset( $_GET[ 'pageno' ] ) ) {
    $pageno = ( int )$_GET[ 'pageno' ];
} else {
    $pageno = 1;
}
//step 3
$page_first_result = ( $pageno - 1 ) * $results_per_page;

$baseQuery = "SELECT 
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
    u.user_email,
    u.user_university 
FROM tbl_items i
JOIN tbl_users u ON i.user_id = u.user_id";

$whereClauses[] = "i.item_status != 'sold'";

if ( $search !== 'all' ) {
    $whereClauses[] = "(i.item_name LIKE '%$search%' OR i.item_desc LIKE '%$search%')";
}

if ( $userid !== null ) {
    $whereClauses[] = "i.user_id = '$userid'";
}

if ( !empty( $whereClauses ) ) {
    $baseQuery .= ' WHERE ' . implode( ' AND ', $whereClauses );
}

$sqlloaditems = $baseQuery . ' ORDER BY i.item_date DESC';

//echo $sqlloaditems;
$result = $conn->query( $sqlloaditems );
$number_of_result = $result->num_rows;
$number_of_page = ceil( $number_of_result / $results_per_page );

$sqlloaditems = $sqlloaditems . ' LIMIT ' . $page_first_result . ',' . $results_per_page;

$result = $conn->query( $sqlloaditems );

if ( $result->num_rows > 0 ) {
    $sentArray = array();
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;
    }
    $response = array( 'status' => 'success', 'data' => $sentArray,  'numofpage'=>$number_of_page, 'numberofresult'=>$number_of_result, );
    sendJsonResponse( $response );
} else {
    $response = array( 'status' => 'failed', 'data' => null, 'numofpage'=>$number_of_page, 'numberofresult'=>$number_of_result, );
    sendJsonResponse( $response );
}

function sendJsonResponse( $sentArray )
 {
    header( 'Content-Type: application/json' );
    echo json_encode( $sentArray );
}

?>
