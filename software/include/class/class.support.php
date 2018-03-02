<?php
    class support {

        public function getSupportUsr($token) {
            try {
                include 'connection.php';

                $opt = 1;
                $asunto = '';
                $mensaje = '';

                $call = $conecta->prepare('CALL sp_supportUsr(?, ?, ?, ?)');
                $call->bind_param('sssi', $token, $asunto, $mensaje, $opt);
                $call->execute();
                $call->bind_result($folio, $dia, $hora, $asuntoR, $estado);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $ticketArray = array();
                    while($call->fetch()){
                        $aTempArray = array('folio' => $folio, 'dateS' => $dia, 'hours' => $hora, 'asunto' => $asunto, 'estado' => $estado);
                        array_push($ticketArray, $aTempArray);
                    }
                    $resp = array('status' => 200, 'data' => $ticketArray);
                    echo json_encode($resp);
                }

            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function setSupportUsr($token, $asunto, $mensaje) {
            try {
                include 'connection.php';

                $opt = 2;

                $call = $conecta->prepare('CALL sp_supportUsr(?, ?, ?, ?)');
                $call->bind_param('sssi', $token, $asunto, $mensaje, $opt);
                $call->execute();
                $call->bind_result($m);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => $m);
                    echo json_encode($resp);
                }

            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }
    }
?>