<?php
    class agendaDates {

        public function getAllDates($token){
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllDates(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($start, $end, $title, $status, $statusDesc, $titleDesc);
                //var_dump($call);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->bind_result($sessToken, $names, $lastnames);
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => ['start' => $start, 'end' => $end, 'title' => $title, 'datestatus' => $status, 'statusDesc' => $statusDesc, 'titleDesc' => $titleDesc]);
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