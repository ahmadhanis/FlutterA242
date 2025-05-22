<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *"); // running as crome app
include_once("dbconnect.php");

$sqlloaditems= "SELECT * FROM `tbl_items`";
//echo $sqlloaditems;
$result = $conn->query($sqlloaditems);
if ( $result->num_rows > 0 ) {
     $sentArray = array();
    while ( $row = $result->fetch_assoc() ) {
        $sentArray[] = $row;
    }
     $response = array( 'status' => 'success', 'data' => $sentArray);
      sendJsonResponse( $response );
}else{
    $response = array( 'status' => 'failed', 'data' => null);
    sendJsonResponse( $response );
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
