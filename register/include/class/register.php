<?php
    class Register {

        public function addUser($name, $lastname, $email, $pwd) {
            
            include 'class/connection.php';

            $arreglo = array('name' => $name, 'lastname'=> $lastname, 'email'=>$email, 'passwd'=>$pwd);
            
            $call = $conecta->prepare('CALL sp_newUser(?,?,?,?)');
            $call->bind_param('ssss', $name, $lastname, $email, $pwd);
            $call->execute();
            echo $call->affected_rows;
            while ($row = $call->fetch_array(MYSQLI_ASSOC)) {
                echo $row['usr_name'];
            }
            //echo json_encode($arreglo);
        }
    }
?>