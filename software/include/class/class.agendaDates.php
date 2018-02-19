<?php
    class agendaDates {

        public function getAllDates($token){
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllDates(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($start, $end, $title, $status, $statusDesc, $titleDesc, $color);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $dateprog = array();
                    while ($call->fetch()){
                        $arrayTemp = array('start' => $start, 'end' => $end, 'title' => $title, 'datestatus' => $status, 'statusDesc' => $statusDesc, 'titleDesc' => $titleDesc, 'color' => $color);
                        array_push($dateprog, $arrayTemp);
                    }
                    $resp = array('status' => 200, 'data' => $dateprog);
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function setDates($token, $dStart, $dEnd, $optionC) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_setNewDate(?, ?, ?, ?)');
                $call->bind_param('sssi', $token, $dStart, $dEnd, $optionC);
                $call->execute();
                $call->bind_result($mess);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => $mess);
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getWarningsUsr($token) {
            try {
                $opt = 1;
                $citaId = 0;
                $dStart = '';
                $dEnd = '';
                $dateStatus = 0;
                
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_checkNewDatesUsr(?, ?, ?, ?, ?, ?)');
                $call->bind_param('siiiss', $token, $opt, $citaId, $dateStatus, $dStart, $dEnd);
                $call->execute();
                $call->bind_result($cId, $cDstart, $cDend, $dType, $dStatus, $dBadge,$dpName);
                
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $newDatesW = array();
                    while($call->fetch()){
                        $aTemp = array('cId' => $cId, 'dStart' => $cDstart, 'dEnd' => $cDend, 'dType' => $dType, 'dStatus' => $dStatus, 'dpName' => $dpName, 'dBadge' => $dBadge);
                        array_push($newDatesW,$aTemp);
                    }
                    $resp = array('status' => 200, 'data' => $newDatesW);
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getWarningsStaff($token) {
            try {
                include 'conection.php';

                $opt = 1;
                $citaId = 0;
                $dStart = '';
                $dEnd = '';

                $call = $conecta->prepare('CALL sp_checkNewDatesStaff(?, ?, ?, ?, ?, ?)');
                $call->bind_param('siiiss', $token, $opt, $citaId,$dStart, $dEnd);
                $call->execute();
                $call->bind_result($cId, $cDstart, $cDend, $dType, $dStatus, $dpName);
                
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $newDatesW = array();
                    while($call->fetch()){
                        $aTemp = array('cId' => $cId, 'dStart' => $cDstart, 'dEnd' => $cDend, 'dType' => $dType, 'dStatus' => $dStatus, 'dpName' => $dpName);
                        array_push($newDatesW,$aTemp);
                    }
                    $resp = array('status' => 200, 'data' => $newDatesW);
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function setReviewWarnings($token,$option){
            try {

                $opt = strpos($option, 't_');
                echo $opt.'<br>';
                $cId = substr($option, $opt + 2);
            
                
                if ($opt === false) {
                    $optNot = array('status' => 404, 'errno' => 1100, 'message' => 'Cita no encontrada');
                    echo json_encode($optNot).'<br>';
                } else {
                    echo $cId.'<br>';
                    $userType = $_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'];
                    echo $userType;
                    $call = $conecta->prepare('CALL sp_reviewDate(?, ?, ?)');
                    $call->bind_param('sii', $token, $userType, $cId);
                    // $call->execute();
                    // $call->bind_result($statusV);
                    
                    // if ($call->errno > 0) {
                    //     $errno = $call->errno;
                    //     $msg = $call->error;
                    //     $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    //     echo json_encode($resp);
                    // } else {
                    //     $resp = array('status' => 200, 'data' => $statusV);
                    //     echo json_encode($resp);
                    // }
                }
                echo 'token sesion - '.$_SESSION['9987435b7dbef543b786efd81d1b3dc9'].'<br>';
                echo 'token - '.$token.'<br>';
                echo 'sesion - '.$_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'];
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
            
        }
    }

?>