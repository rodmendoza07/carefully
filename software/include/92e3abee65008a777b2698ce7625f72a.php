<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.support.php';
        session_start();

        $supportUsr = new support();
        $supportUsr->getSupportUsr(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']));
    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>