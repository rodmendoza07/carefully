<?php
    class getInfoUser {
        
        public function accessLogin($userName, $passwd) {
            try {
                include 'connection.php';
    
                $call = $conecta->prepare('CALL sp_getInfoUser(?,?)');
                $call->bind_param('ss', $userName, $passwd);
                $call->execute();
    
                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    session_start();
                    $call->bind_result($sessToken, $names, $lastnames, $urlLocation, $typeUser, $therapist, $menu_id, $menu_parent, $menu_desc);
                    $arraymenu = array();
                    $i = 0;
                    $j = 1;
                    //$arrayParent = array();
                    while ($call->fetch()) {
                        // if($menu_parent == 0) {
                        //     if ($i == $j) {
                        //         array_push($arraymenu, $arrayParent);
                        //     }
                        //     $arrayParent = array(utf8_encode($menu_desc));
                        //     $i = $menu_id;
                        //     echo $i."<br>";
                        //     //array_push($arraymenu, $arrayParent);
                        // } else {
                        //     $arrayChild = array(utf8_encode($menu_desc));
                        //     array_push($arrayParent, $arrayChild);
                        //     $j = $menu_parent;
                        //     echo $j."<br>";
                        //     //$i++;
                        // }
                    }
                    // echo "<pre>";
                    // var_dump($arraymenu);
                    // echo "</pre>";
                    //var_dump($arraymenu);
                    //echo json_encode($arraymenu);
                    // $call->fetch();
                    $_SESSION['9987435b7dbef543b786efd81d1b3dc9'] = $sessToken;
                    $_SESSION['e4595499803bf2733cc9cb8e55c6ece3'] = $names;
                    $_SESSION['089e07ac4b0332dfc7fe1e4f0197fc11'] = $lastnames;
                    $_SESSION['5ac7fb09a5264f6d78424dbdbf3f9187'] = $typeUser;
                    $_SESSION['c31628f91db9e419fa043ecf38bf3af4'] = $therapist;
                    //echo $menu_id;
                    $resp = array('status' => 200, 'data' => 'Ok', 'urlLoc' => $urlLocation);
                    echo json_encode($resp);
                }
                $call->close();
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function validateSess($token) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_validateToken(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($message);
                $call->fetch();

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    session_start();
                    session_unset();
                    session_destroy();
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    return true;
                    $resp = array('status' => 200, 'message' => $message, 'data' => $token);
                    //echo json_encode($resp);
                }
            } catch (Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function profileUsr($token) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getProfileUsr(?)');
                $call->bind_param('s', $token);
                $call->execute();
                $call->bind_result($name, $idGender, $gender, $idNac, $nation, $age, $birthDate, $idCs, $civilState, $phoneContact, $email, $aditional, $famHist, $df, $mc, $pa, $am, $psic, $traumas, $ps);
                $call->fetch();

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $resp = array('status' => 200, 'name' => $name, 'idGender' => $idGender, 'gender' => $gender, 'idNac' => $idNac,'nation' => utf8_encode($nation), 'age' => $age, 'birthdate' => $birthDate, 'idCs' => $idCs, 'civilState' => $civilState, 'phoneContact' => $phoneContact, 'email' => $email, 'aditional' => $aditional, 'famHist' => $famHist, 'df' => $df, 'mc' => $mc, 'pa' => $pa, 'am' => $am, 'psic' => $psic, 'traumas' => $traumas, 'ps' => $ps);
                    echo json_encode($resp);
                }

            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getAllCivilS() {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllCe()');
                $call->execute();
                $call->bind_result($ceId, $ceDesc);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $estadosCiviles = array();
                    while ($call->fetch()) {
                        $aTemp = array('ceId' => $ceId, 'ceDesc' => utf8_encode($ceDesc));
                        array_push($estadosCiviles,$aTemp);
                    }
                    $resp = array('status' => 200, 'data' => $estadosCiviles);
                    echo json_encode($resp);
                }

            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getAllGenders() {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllgender()');
                $call->execute();
                $call->bind_result($gId, $gDesc);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $generos = array();
                    while ($call->fetch()) {
                        $aTemp = array('gId' => $gId, 'gDesc' => utf8_encode($gDesc));
                        array_push($generos,$aTemp);
                    }
                    $resp = array('status' => 200, 'data' => $generos);
                    echo json_encode($resp);
                }

            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getAllN() {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllNations()');
                $call->execute();
                $call->bind_result($nId, $nDesc);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $nations = array();
                    while ($call->fetch()) {
                        $aTemp = array('nId' => $nId, 'nDesc' => utf8_encode($nDesc));
                        array_push($nations,$aTemp);
                    }
                    $resp = array('status' => 200, 'data' => $nations);
                    echo json_encode($resp);
                }

            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }

        public function getFaqsUsr($token, $tp) {
            try {
                include 'connection.php';

                $call = $conecta->prepare('CALL sp_getAllFaqs(?,?)');
                $call->bind_param('ss', $token, $tp);
                $call->execute();
                $call->bind_result($qId, $qQuestion, $aId, $aAnswer, $cDesc, $cat);

                if ($call->errno > 0) {
                    $errno = $call->errno;
                    $msg = $call->error;
                    $resp = array('status' => 500, 'errno' => $errno, 'message' => utf8_encode($msg));
                    echo json_encode($resp);
                } else {
                    $faqs = array();
                    while ($call->fetch()) {
                        $aTemp = array('qId' => $qId, 'qQuestion' => utf8_encode($qQuestion), 'aId' => $aId, 'aAnswer' => utf8_encode($aAnswer), 'cdesc' => utf8_encode($cDesc), 'cat' => $cat);
                        array_push($faqs,$aTemp);
                    }
                    $resp = array('status' => 200, 'data' => $faqs);
                    echo json_encode($resp);
                }
                
            } catch(Exception $e) {
                $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
                echo json_encode($catch);
            }
        }
    }
?>