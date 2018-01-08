<?php
    error_reporting(E_ERROR | E_PARSE);
    include 'class/class.register.php';

    try {
        // $userEmail = $_GET['userEmail'];
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $newPwd = $json_obj['newPwd'];
        $hash_ = $json_obj['hashVal'];

        $rPs = new Register();
        $rPs->restoreNewPass($newPwd, $hash_);

    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>