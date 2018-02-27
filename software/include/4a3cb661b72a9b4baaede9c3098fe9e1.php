<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.mytherapy.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $usrId = $json_obj['usrId'];
        $hf = $json_obj['hf'];
        $df = $json_obj['df'];
        $mc = $json_obj['mc'];
        $hpa = $json_obj['hpa'];
        $am = $json_obj['am'];
        $psi = $json_obj['psi'];
        $trauma = $json_obj['trauma'];
        $ps = $json_obj['ps'];

        $usrBit = new mytherapy();
        $usrBit->setBitacoraPatient(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $usrId, $hf, $df, $mc, $hpa, $am, $psi, $trauma, $ps);

    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }

?>