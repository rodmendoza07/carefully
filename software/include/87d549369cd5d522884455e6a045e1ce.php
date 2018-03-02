<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.support.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $subject = $json_obj['ssubjcet'];
        $msg = $json_obj['smessage'];

        $setTicket = new support();  
        $setTicket->setSupportStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $subject, $msg);
            
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>