<?php
    include 'class/register.php';

    $json_str = file_get_contents('php://input');
    $json_obj = json_decode($json_str, true);
    $opt = $json_obj['opt'];
    $newUser = new Register();

    switch ($opt) {
        case '1':
            $name = $json_obj['names'];
            $lastname = $json_obj['lastnames'];
            $email = $json_obj['userEmail'];
            $pwd = $json_obj['pwd'];
            $user = 
            $newUser->addUser($name, $lastname, $email, $pwd);
            break;
        
        default:
            # code...
            break;
    }

?>