<?php
    include 'class/register.php';
    include 'class/connection.php';

    //$json_str = file_get_contents('php://input');
    //$json_obj = json_decode($json_str, true);
    //$opt = $json_obj['opt'];
    $opt = 1;
    $newUser = new Register();

    switch ($opt) {
        case '1':
            // $name = $json_obj['names'];
            // $lastname = $json_obj['lastnames'];
            // $email = $json_obj['userEmail'];
            // $pwd = $json_obj['pwd'];
            $name = 'a';
            $lastname = 'b';
            $email = 'c@c';
            $pwd = '12345678';

            $call = $conecta->prepare('CALL sp_newUser(?,?,?,?)');
            $call->bind_param('ssss', $name, $lastname, $email, $pwd);
            $call->execute();
            $call->bind_result($dato1, $dato2);

            while ($call->fetch()) {
                echo 'dato1 - '.$dato1.'dato2 - '.$dato2.'<br>';
            }

            var_dump($call->num_rows);
            var_dump($call->get_result());
            $call->free_result();

            //$newUser->addUser($name, $lastname, $email, $pwd);
            break;
        
        default:
            # code...
            break;
    }

?>