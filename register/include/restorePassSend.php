<?php
    error_reporting(E_ERROR | E_PARSE);
    include 'class/class.register.php';

    try {
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $userEmail = $json_obj['userEmail'];

        $rPs = new Register();

        $rPs->restorePassSend($userEmail);

    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>