<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.getInfoUser.php';
        session_start();

        $faqs = new getInfoUser();
        $faqs->getFaqsUsr();
    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>