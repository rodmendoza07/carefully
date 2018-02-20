<?php
    error_reporting(E_ERROR | E_PARSE);
    include 'class/class.getInfoUser.php';

    try{
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $userName = $json_obj['userName'];
        $passwd = $json_obj['passwd'];

        // $userName = 'lr.mendozar@gmail.com';
        // $passwd = '12345678';

        $newAccess = new getInfoUser();
        $newAccess->accessLogin($userName, $passwd);

    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>