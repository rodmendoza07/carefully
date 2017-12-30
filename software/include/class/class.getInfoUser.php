<?php
    class getInfoUser {
        
        public function accessLogin($userName, $passwd) {
            try {
                include 'connection.php';
    
                $call = $conecta->prepare('sp_getInfoUser(?,?)');
                $call->bind_param('ss', $userName, $passwd);
                $call->execute();
    
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->bind_result($sessToken, $names, $lastnames);
                    while ($call->fetch()) {
                        $resp = array('status' => 200, 'data' => ['sessToken' => $sessToken, 'names' => $names, 'lastnames' => $lastnames]);
                        echo json_encode($resp);
                    }
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }
    }
?>