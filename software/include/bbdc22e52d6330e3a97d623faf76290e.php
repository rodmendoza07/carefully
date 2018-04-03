<?php
    //error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.agendaDates.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $dOld = $json_obj['dOld'];
        $dNew = $json_obj['dNew'];
        $dEnd = $json_obj['dEnd'];

        $reprogram = new agendaDates();

        $reprogram->reprogramStaff($_SESSION['9987435b7dbef543b786efd81d1b3dc9'], $dOld, $dNew, $dEnd);

    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>