<?php
    error_reporting(E_ERROR | E_PARSE);
    include 'class/class.register.php';

    try {
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $opt = $json_obj['opt'];
        $newUser = new Register();
        
        switch ($opt) {
            case '1':
                $name = strip_tags($json_obj['names']);
                $lastname = strip_tags($json_obj['lastnames']);
                $email = strip_tags($json_obj['userEmail']);
                $pwd = strip_tags($json_obj['pwd']);
                $newUser->addUser($name, $lastname, $email, $pwd, $opt);
                break;
            default:
                $default = array('status' => 401, 'errno' => 1002, 'message' => 'Opción inválida');
                break;
        }
    }  catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    } 
?>