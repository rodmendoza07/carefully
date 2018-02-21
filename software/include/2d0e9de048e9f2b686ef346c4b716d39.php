<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.agendaDates.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $cId = $json_obj['cId'];
        $prevStatus = $json_obj['prevS'];

        // $cId = 'acept_3';

        $opt = strpos($cId, 't_');
        $ccId = substr($cId, $opt + 2);

        if ($opt === false) {
            $sCancel = strpos($ccId, 'l_');
            $ccId = substr($ccId, $sCancel + 2);
            $typeOperation = 4;
        } else {
            $typeOperation = 2;
        }

        $getAllWarnings = new agendaDates();

        switch($typeOperation) {
            case '2':
                    if ($_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'] == 0) {
                        switch($prevStatus) {
                            case 'Cancelada':
                                /** El cliente acepta la cita cancelada del staff */
                                $getAllWarnings->setReviewWarnings(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId);
                                break;
                            case 'Agendada':
                                /** El cliente acepta la cita agendada del staff */
                                $getAllWarnings->setReviewWarnings(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId);
                                break;
                            default:
                                $optNot = array('status' => 401, 'errno' => 1100, 'message' => 'Acción inválida');
                                break;
                        }
                    } else {
                        switch($prevStatus){
                            case 'Cancelada':
                                /** El staff acepta la cita cancelada del cliente */
                                $getAllWarnings->setReviewWarnings(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId);
                                break;
                            case 'Enviada':
                                /** El staff cambia el status de alguna sesión menos las enviadas por el paciente */
                                $getAllWarnings->changeStatusDateStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId, $typeOperation, '', '');
                                break;
                            default:
                                $optNot = array('status' => 401, 'errno' => 1100, 'message' => 'Acción inválida');
                                break;
                        }
                    }
                    break;
            
            case '4':
                    if ($_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'] == 0) {
                        //echo 'entro a clientes cancelar';
                        $getAllWarnings->changeStatusDateUsr(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId, $typeOperation, '', '');
                    } else {
                        //echo 'entro a cancelar';
                        $getAllWarnings->changeStatusDateStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId, $typeOperation, '', '');
                    }
                    break;
            
            default:
                    $optNot = array('status' => 404, 'errno' => 1100, 'message' => 'Cita no encontrada');
                    break;
        }
        
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>