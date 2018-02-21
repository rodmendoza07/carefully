<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.agendaDates.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $cId = $json_obj['cId'];

        // $cId = 'acept_3';

        $opt = strpos($cId, 't_');
        $ccId = substr($cId, $opt + 2);

        $opt === false ? $typeOperation = 4 : $typeOperation = 2;

        $getAllWarnings = new agendaDates();

        switch($typeOperation) {
            case '2':
                    if ($_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'] == 0) {
                        $getAllWarnings->setReviewWarnings(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId);
                    } else {
                        $getAllWarnings->changeStatusDateStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $typeOperation, $ccId, $typeOperation, '', '');
                    }
                    break;
            
            case '4':
                    if ($_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'] == 0) {
                        
                    } else {
                        echo 'entro a cancelar';
                        $getAllWarnings->changeStatusDateStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), 2, $ccId, $typeOperation, '', '');
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