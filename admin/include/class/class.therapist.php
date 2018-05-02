<?php
    class Therapist {
        
        public function newTherapist($token, $name, $fname, $lname, $email, $service) {
            try {
                include 'connection.php';

                $department = 3;
                $job = 3;
               
                $call = $conecta->prepare('CALL sp_setNewStaff(?, ?, ?, ?, ?, ?, ?, ?)');
                $call->bind_param('ssssssii', $token, $name, $fname, $lname, $email, $service, $department, $job);
                $call->execute();
                $call->bind_result($response);
                
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $call->fetch();
                    $resp = array('status' => 200, 'data' => $response);
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