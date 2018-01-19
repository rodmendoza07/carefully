<?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.agendaDates.php';
        session_start();
        $json_str = file_get_contents('php://input');
        $json_obj = json_decode($json_str, true);
        $dStart = $json_obj['dStart'];
        $dEnd = $json_obj['dEnd'];
        $dCom = $json_obj['dCom'];

        // $dStart = '2018-01-19 16:45:00';
        // $dEnd = '2018-01-19 17:35:00';
        // $dCom = 1;
        
        //$_SESSION['9987435b7dbef543b786efd81d1b3dc9'] = 'ad9cfdff972dd2d5dc132195fa706f64';
        //echo $dStart.$dEnd.$dCom;
        //if (isset($_SESSION['9987435b7dbef543b786efd81d1b3dc9']) && !empty($_SESSION['9987435b7dbef543b786efd81d1b3dc9'])) {
            //echo $_SESSION['9987435b7dbef543b786efd81d1b3dc9'];
            $setDate = new agendaDates();  
            $setDate->setDates(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']), $dStart, $dEnd, $dCom);
            //$setDate->setDates('278628d2f65f14abfd5e370b66500fee', $dStart, $dEnd, $dCom);
            


        //} else {
          //  $resp = array('status' => 401, 'errno' => 1002, 'message' => 'Denied');
           // echo json_encode($resp);
        //}
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>