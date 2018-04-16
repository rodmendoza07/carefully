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

        public function getAllDatesStaff($token){
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllDatesStaff(?)');
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

                $opt = 1;
                $citaId = 0;
                $dStart = '';
                $dEnd = '';
                $dateStatus = 0;
                
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_checkNewDatesStaff(?, ?, ?, ?, ?, ?)');
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

        public function setReviewWarnings($token,$option){
            try {

                include 'connection.php';
                
                $userType = $_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'];
                $call = $conecta->prepare('CALL sp_reviewDate(?, ?, ?)');
                $call->bind_param('sii', $token, $userType, $option);
                $call->execute();
                $call->bind_result($idDev);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => $idDev);
                    echo json_encode($resp);
                }
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
            
        }

        public function cancelWarning($token,$idDate) {
            try {
                include 'connection.php';

                $opt = 2;
                $dStart = '';
                $dEnd = '';

                $call = $conecta->prepare('CALL sp_checkNewDatesUsr(?, ?, ?, ?, ?, ?)');
                $call->bind_param('siiiss', $token, $opt, $idDate,$dStart, $dEnd);
                $call->execute();
                $call->bind_result($statusV);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => $statusV);
                    echo json_encode($resp);
                }
                
            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function changeStatusDateStaff($token, $cId, $dateStatus, $dStart, $dEnd) {
            try {
                include 'connection.php';

                $opt = 2;

                // echo $token.'token<br>';
                // echo $dateStatus.'estado cita<br>';
                // echo $cId.'id de cita<br>';
                // echo $dStart.'inicio<br>';
                // echo $dEnd.'termino<br>';

                $call = $conecta->prepare('CALL sp_checkNewDatesStaff(?, ?, ?, ?, ?, ?)');
                $call->bind_param('siiiss', $token, $opt, $cId, $dateStatus, $dStart, $dEnd);
                $call->execute();
                $call->bind_result($statusV);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => $statusV);
                    echo json_encode($resp);
                }

            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function changeStatusDateUsr($token, $cId, $dateStatus, $dStart, $dEnd) {
            try {
                include 'connection.php';

                $opt = 2;

                // echo $token.'token<br>';
                // echo $dateStatus.'estado cita<br>';
                // echo $cId.'id de cita<br>';
                // echo $dStart.'inicio<br>';
                // echo $dEnd.'termino<br>';

                $call = $conecta->prepare('CALL sp_checkNewDatesUsr(?, ?, ?, ?, ?, ?)');
                $call->bind_param('siiiss', $token, $opt, $cId, $dateStatus, $dStart, $dEnd);
                $call->execute();
                $call->bind_result($statusV);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $resp = array('status' => 200, 'data' => $statusV);
                    echo json_encode($resp);
                }

            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function setDatesStaff($token, $dStart, $dEnd) {
            try {
                include 'connection.php';

                $optBloq = 1;
                $dateStartOld = '';

                $call = $conecta->prepare('CALL sp_blockDoctorDates(?, ?, ?, ?, ?)');
                $call->bind_param('sssis', $token, $dStart, $dEnd, $optBloq, $dateStartOld);
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

        public function getPatientNames($token, $typePerson, $dStart) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getPatientDocNames(?, ?, ?)');
                $call->bind_param('sis', $token, $typePerson, $dStart);
                $call->execute();
                $call->bind_result($perName);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => $perName);
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function editDatesStaff($token, $dStart, $dEnd, $dOld) {
            try {
                include 'connection.php';

                $optBloq = 2;

                $call = $conecta->prepare('CALL sp_blockDoctorDates(?, ?, ?, ?, ?)');
                $call->bind_param('sssis', $token, $dStart, $dEnd, $optBloq, $dOld);
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

        public function unblockStaff($token, $dOld) {
            try {
                include 'connection.php';

                $optBloq = 2;
                $dStart = '0000-00-00 00:00:00';
                $dEnd = '0000-00-00 00:00:00';

                $call = $conecta->prepare('CALL sp_blockDoctorDates(?, ?, ?, ?, ?)');
                $call->bind_param('sssis', $token, $dStart, $dEnd, $optBloq, $dOld);
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

        public function reprogramStaff($token, $dOld, $ddNew, $ddEnd){
            try {
                include 'connection.php';

                $opt = 1;

                $call = $conecta->prepare('CALL sp_editEventStaff(?, ?, ?, ?, ?)');
                $call->bind_param('sssis', $token, $ddNew, $ddEnd, $opt, $dOld);
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
    }
?>