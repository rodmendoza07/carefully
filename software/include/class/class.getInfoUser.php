<?php
    class getInfoUser {
        
        public function accessLogin($userName, $passwd) {
            try {
                include 'connection.php';
    
                $call = $conecta->prepare('CALL sp_getInfoUser(?,?)');
                $call->bind_param('ss', $userName, $passwd);
                $call->execute();
    
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    session_start();
                    $call->bind_result($sessToken, $names, $lastnames);
                    $call->fetch();
                    $_SESSION['9987435b7dbef543b786efd81d1b3dc9'] = $sessToken;
                    $_SESSION['e4595499803bf2733cc9cb8e55c6ece3'] = $names;
                    $_SESSION['089e07ac4b0332dfc7fe1e4f0197fc11'] = $lastnames;
                    $resp = array('status' => 200, 'data' => 'Ok');
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function validateSess($token) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_validateToken(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($message);
                $call->fetch();

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $resp = array('status' => 200, 'message' => $message, 'data' => $token);
                    echo json_encode($resp);
                }
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }
    }
?>