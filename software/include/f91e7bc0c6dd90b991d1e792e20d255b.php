<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.getInfoUser.php';
        session_start();
        
        $faqs = new getInfoUser();
        $faqs->getFaqsUsr(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), strip_tags($_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187']));
    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>