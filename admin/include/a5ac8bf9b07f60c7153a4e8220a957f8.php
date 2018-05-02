<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.therapist.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $tId = $json_obj["tId"];
        $name = $json_obj["name"];
        $fname = $json_obj["fname"];
        $lname = $json_obj["lname"];
        $service = $json_obj["service"];

        $editTh = new Therapist();  
        $editTh->editTherapiest(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $tId, $name, $fname, $lname, $service);
        
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>