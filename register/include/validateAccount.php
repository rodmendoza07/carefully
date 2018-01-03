<?php
    error_reporting(E_ERROR | E_PARSE);
    include 'class/class.register.php';

    try {
        $codeAccount = $_GET['code'];
        $validAccount = new Register();

        $validAccount->validateAccount($codeAccount);

    } catch(Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>