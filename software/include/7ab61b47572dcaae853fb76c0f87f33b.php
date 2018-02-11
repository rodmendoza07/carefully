<?php
    <?php
    error_reporting(E_ERROR | E_PARSE);
    try {
        include 'class/class.agendaDates.php';
        session_start();
        
        //$_SESSION['9987435b7dbef543b786efd81d1b3dc9'] = 'ad9cfdff972dd2d5dc132195fa706f64';

        //if (isset($_SESSION['9987435b7dbef543b786efd81d1b3dc9']) && !empty($_SESSION['9987435b7dbef543b786efd81d1b3dc9'])) {
            //echo $_SESSION['9987435b7dbef543b786efd81d1b3dc9'];
            $getAllWarnings = new agendaDates();  
            $getAllWarnings->getWarningsStaff(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']));
            //$getAllDates->getAllDates('872c7098627a16be698bbc3d0b015a2d');
            


        //} else {
          //  $resp = array('status' => 401, 'errno' => 1002, 'message' => 'Denied');
           // echo json_encode($resp);
        //}
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>
?>