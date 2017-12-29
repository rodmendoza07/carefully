<?php
    class Register {

        public function addUser($name, $lastname, $email, $pwd) {
            
            include 'class/connection.php';

            $arreglo = array('name' => $name, 'lastname'=> $lastname, 'email'=>$email, 'passwd'=>$pwd);
            $call = $conecta->prepare('CALL sp_newUser(?,?,?,?, @name,@lastname,@email,@pwd)');
            $call->bind_param('iiii', $name, $lastname, $email, $pwd);
            $call->execute();
            echo json_encode($arreglo);
        }
    }
?>