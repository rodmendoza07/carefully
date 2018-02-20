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
                    $getAllWarnings->setReviewWarnings(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId);
                    break;
            
            case '4':
                    $getAllWarnings->cancelWarning(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $ccId);
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