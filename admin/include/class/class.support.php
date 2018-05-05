<?php
    class Support {
        
        public function getAllTickets($token) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllTickets(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($folio, $dateS, $hours, $asunto, $estado, $nombre, $userAccount, $typePerson);
                
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $tickets = array();
                    while ($call->fetch()) {
                        $aTemp = array('folio' => $folio, 'dateS' => $dateS, 'hours' =>$hours, 'asunto' => $asunto, 'estado' => $estado, 'nombre' => $nombre, 'userAccount' => $userAccount, 'typePerson' => $typePerson);
                        array_push($tickets,$aTemp);
                    }
                    $resp = array('status' => 200, 'data' => $tickets);
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getDetail() {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllTickets(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($folio, $dateS, $hours, $asunto, $estado, $nombre, $userAccount, $comment);
                
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    
                    $call->fetch();
                        $aTemp = array('folio' => $folio, 'dateS' => $dateS, 'hours' =>$hours, 'asunto' => $asunto, 'estado' => $estado, 'nombre' => $nombre, 'userAccount' => $userAccount, 'comment' => $comment);
                        array_push($tickets,$aTemp);
                    
                        $resp = array('status' => 200, 'data' => $tickets);
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