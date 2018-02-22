<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.mytherapy.php';
        session_start();

        $getTh = new mytherapy();

        switch(strip_tags($_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'])) {
            case '0':
                $getTh->getMyTherapyUsr(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']));
                break;

            case '1':
                $getTh->getMyTherapyStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']));
                break;

            default:
                $optNot = array('status' => 401, 'errno' => 1100, 'message' => 'Acción inválida');
                echo json_encode($optNot);
                break;
        }

    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>