<?php
    class mytherapy {

        public function getMyTherapyUsr($token) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getMyTherapyUsr(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($dia, $horario, $typeDate, $names);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $eventArray = array();
                    while($call->fetch()){
                        $aTempArray = array('day' => $dia, 'horario' => $horario, 'status' => $typeDate, 'names' => $names);
                        array_push($eventArray, $aTempArray);
                    }
                    $resp = array('status' => 200, 'data' => $eventArray);
                    echo json_encode($resp);
                }

            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getMyTherapyStaff($token) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getMyTherapyStaff(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($dia, $horario, $typeDate, $names);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $eventArray = array();
                    while($call->fetch()){
                        $aTempArray = array('day' => $dia, 'horario' => $horario, 'status' => $typeDate, 'names' => $names);
                        array_push($eventArray, $aTempArray);
                    }
                    $resp = array('status' => 200, 'data' => $eventArray);
                    echo json_encode($resp);
                }

            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getAllPatients($token) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllPatients(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($uId, $uName);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $patients = array();
                    while($call->fetch()){
                        $aTempArray = array('uId' => $uId, 'uName' => $uName);
                        array_push($patients, $aTempArray);
                    }
                    $resp = array('status' => 200, 'data' => $patients);
                    echo json_encode($resp);
                }

            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }
    }
?>