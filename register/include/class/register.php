<?php
    class Register {
        
        public function addUser($usuario) {
            $arreglo = array('userName' => $usuario);
            echo json_encode($arreglo);
        }
    }
?>