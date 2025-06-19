<?php
include_once( 'dbconnect.php' );

$userid = $_POST[ 'userid' ];
$name = $_POST[ 'name' ];
$phone = $_POST[ 'phone' ];
$address = $_POST[ 'address' ];
$image = $_POST[ 'image' ];

$sql = "UPDATE tbl_users SET user_name='$name', user_phone='$phone', user_address='$address' WHERE user_id = '$userid'";
if ( $conn->query( $sql ) === TRUE ) {
    if ( $image !== 'NA' ) {
        $decoded_image = base64_decode( $image );
        $filename = "../assets/images/profiles/$userid.png";
        file_put_contents( $filename, $decoded_image );
    }
    echo json_encode( [ 'status' => 'success' ] );
} else {
    echo json_encode( [ 'status' => 'fail' ] );
}
?>
