<?php
    include 'class/register.php';

    $opt = $_GET["opt"];
    $newUser = new Register();

    switch ($opt) {
        case '1':
            $newUser->addUser('pepito perez'); 
            break;
        
        default:
            # code...
            break;
    }

?>