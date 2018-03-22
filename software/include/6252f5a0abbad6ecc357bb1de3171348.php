<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.agendaDates.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $dStart = $json_obj['dStart'];
        $dEnd = $json_obj['dEnd'];

        $setDate = new agendaDates();  
        $setDate->setDatesStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $dStart, $dEnd);
            
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>