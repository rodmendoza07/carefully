<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.getInfoUser.php';
        session_start();

        $n = new getInfoUser();
        $n->getAllN();
    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>