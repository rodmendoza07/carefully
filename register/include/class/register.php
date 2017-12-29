<?php
    class Register {

        public function addUser($name, $lastname, $email, $pwd, $opt) {
            try {
                include 'class/connection.php';
                
                $opt = (int)$opt;
                $call = $conecta->prepare('CALL sp_newUser(?,?,?,?,?)');
                $call->bind_param('ssssi', $name, $lastname, $email, $pwd, $opt);
                $call->execute();
                
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('estatus' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->bind_result($hash);
                    while ($call->fetch()) {
                        $resp = array('estatus' => 200, 'data' => $hash);
                        echo json_encode($resp);
                    }
                }
            } catch (Exception $e) {
                echo $e;
            }
        }
    }
?>