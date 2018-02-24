<?php
    try {
        include '../include/class/class.getInfoUser.php';
        session_start();
    
        if (!isset($_SESSION['9987435b7dbef543b786efd81d1b3dc9']) && empty($_SESSION['9987435b7dbef543b786efd81d1b3dc9'])) {    
          echo "entro aqui";  
          //header('location: ../../register/login.html');
        } else {
          $validS = new getInfoUser();    
          $validatesta = $validS->validateSess(strip_tags($_SESSION['9987435b7dbef543b786efd81d1b3dc9']));
          if ($validatesta != true) {
            header('Location: ../../register/login.html');
          } else {
            $cName = $_SESSION['e4595499803bf2733cc9cb8e55c6ece3']." ".$_SESSION['089e07ac4b0332dfc7fe1e4f0197fc11'];
            echo $validatesta;
          }
        }
    } catch (Exception $e) {
        $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
        echo json_encode($catch);
    }
?>
