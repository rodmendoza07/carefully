<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.therapist.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $tId = $json_obj["tId"];

        $banTh = new Therapist();  
        $banTh->banTherapiest(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $tId);
        
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>