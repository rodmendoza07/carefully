<?php
    try {
        include 'class/class.getInfoUser.php';
        session_start();
    
        if (isset($_SESSION['9987435b7dbef543b786efd81d1b3dc9']) && !empty($_SESSION['9987435b7dbef543b786efd81d1b3dc9'])) {
            
            $validS = new getInfoUser();    
            $validS->validateSess(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']));
    
        } else {
            $resp = array('status' => 401, 'errno' => 1002, 'message' => 'Denied');
            echo json_encode($resp);
        }
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }

?>