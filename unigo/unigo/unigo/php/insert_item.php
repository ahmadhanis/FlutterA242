<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *"); // running as crome app

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$name = $_POST['name'];
$description = $_POST['description'];
$status = $_POST['status'];
$quantity = $_POST['quantity'];
$userid = $_POST['userid'];
$image = base64_decode($_POST['image']);
$price = $_POST['price'];
$delivery = $_POST['delivery'];

$sqlinsert="INSERT INTO `tbl_items`(`user_id`, `item_name`, `item_desc`, `item_status`, `item_qty`, `item_price`, `item_delivery`) VALUES ('$userid','$name','$description','$status','$quantity','$price','$delivery')";

try{
    if ($conn->query($sqlinsert) === TRUE) {
        $last_id = $conn->insert_id;
         $path = "../assets/images/items/item-".$last_id.".png";
        file_put_contents($path, $image);
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }   
}catch (Exception $e) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}
	

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
