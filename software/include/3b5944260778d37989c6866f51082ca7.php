<?php
    session_start();

    if (isset($_SESSION['9987435b7dbef543b786efd81d1b3dc9']) && !empty($_SESSION['9987435b7dbef543b786efd81d1b3dc9'])) {
        echo 'sesion activa';
    } else {
        echo 'sin sesion';
    }
    

?>