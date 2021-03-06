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
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->bind_result($hash);
                    while ($call->fetch()) {
                        $resp = array('status' => 200, 'data' => $hash);
                        echo json_encode($resp);
                    }
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function validateAccount($codeAccount) {
            try {
                include 'class/connection.php';

                $call = $conecta->prepare('CALL sp_validateAccount(?)');
                $call->bind_param('s', $codeAccount);
                $call->execute();

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->bind_result($status, $activateat);
                    while ($call->fetch()) {
                        $resp = array('status' => 200, 'data' => ['activate' => $status, 'activateat' => $activateat]);
                        echo json_encode($resp);
                    }
                }
                
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }
        
        public function restorePassSend($email) {
            try {
                include 'class/connection.php';

                $call = $conecta->prepare('CALL sp_getNewPwd(?,?,?,?)');
                $opt = -1;
                $pwdNew = "";
                $valHash_ = "";
                $call->bind_param('isss', $opt, $email, $pwdNew, $valHash_);
                $call->execute();

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->bind_result($hashVal);
                    while ($call->fetch()) {
                        $resp = array('status' => 200, 'data' => $hashVal);
                        echo json_encode($resp);
                    }
                }

            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function restoreNewPass($pwdNew, $valHash_){
            try {
                include 'class/connection.php';

                $call = $conecta->prepare('CALL sp_getNewPwd(?,?,?,?)');
                $opt = -2;
                $userEmail = "";
                $call->bind_param('isss', $opt, $userEmail, $pwdNew, $valHash_);
                $call->execute();

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->bind_result($hashVal);
                    while ($call->fetch()) {
                        $resp = array('status' => 200, 'data' => $hashVal);
                        echo json_encode($resp);
                    }
                }

            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }
    }
?>