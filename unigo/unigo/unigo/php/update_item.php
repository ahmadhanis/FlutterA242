<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *"); // running as crome app

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$itemid = $_POST['itemid'];
$name = $_POST['name'];
$description = $_POST['description'];
$status = $_POST['status'];
$quantity = $_POST['quantity'];
$userid = $_POST['userid'];
if ($_POST['image'] !="NA"){
    $image = base64_decode($_POST['image']);
}else{
    $image = "NA";
}
$price = $_POST['price'];
$delivery = $_POST['delivery'];

$sqlupdate="UPDATE tbl_items SET item_name = '$name', item_desc = '$description', item_status = '$status', item_qty = '$quantity', item_price = '$price', item_delivery = '$delivery' WHERE item_id = '$itemid' AND user_id = '$userid'";

try{
    if ($conn->query($sqlupdate) === TRUE) {
        if ($image != "NA") {
            $path = "../assets/images/items/item-".$itemid.".png";
            file_put_contents($path, $image);
        }
        $response = array('status' => 'success', 'data' => $sqlupdate);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => $sqlupdate);
        sendJsonResponse($response);
    }   
}catch (Exception $e) {
    $response = array('status' => 'failed', 'data' => $sqlupdate);
    sendJsonResponse($response);
    die;
}
	

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
