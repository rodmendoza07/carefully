<?php
  $json_str = file_get_contents('php://input');
  $json_obj = json_decode($json_str, true);

  $destination = $json_obj['email'];
  $hash = $json_obj['hash'];
  try {
    $to = $destination;
    $subject = utf8_decode("Activación CuidadosaMENTE");
    
    $message = "
    <div style='margin-left:10px;padding:20px;width:600px;height:325px; border-radius: 25px;border: 2px solid #73AD21;'>
      <h1 style='color:#00C4B3;font-family: Arial, Helvetica, sans-serif;text-align:center;line-height:1.5em;'>Gracias por elegirnos</h1>
      <h1 style='font-family:Arial, Helvetica, sans-serif; text-align: center'>- Es hora de activar tu cuenta -</h1>
      <hr>
      <table width='100%' style='text-align:center; padding-top:25px; padding-bottom:25px;'>
          <tr><td>
              <div>
                <a style='color: #fff !important;text-decoration:none;' href='http://cuidadosamente.com/desarrollo/register/registerValidation.html?code=".$hash."'>
                  <button style='border-radius: 999rem !important; color: #fff !important;
                  border: none !important;
                  background-color: #00C4B3 !important;font-family: Arial, Helvetica, sans-serif;display: inline-block;
                  padding: 6px 12px;
                  margin-bottom: 0;
                  font-size: 14px;
                  font-weight: 400;
                  line-height: 1.42857143;
                  text-align: center;
                  white-space: nowrap;
                  vertical-align: middle;
                  -ms-touch-action: manipulation;
                  touch-action: manipulation;
                  cursor: pointer;
                  -webkit-user-select: none;
                  -moz-user-select: none;
                  -ms-user-select: none;
                  user-select: none;
                  background-image: none;
                  border: 1px solid transparent;
                  border-radius: 4px;-webkit-appearance: button;
                  cursor: pointer;'>Clic aqu&iacute; para activar tu cuenta</button></div>
                </a>
              </div>
          </td>
          </tr>
          <tr>
            <td style='font-family: Arial, Helvetica, sans-serif; padding-top: 15px;'>
              O
            </td>
          </tr>
          <tr>
            <td style='font-family: Arial, Helvetica, sans-serif; padding-top: 15px;'>
              Pega la siguiente direcci&oacuten en tu navegador para activar tu cuenta:
            </td>
          </tr>
          <tr>
            <td style='font-family: Arial, Helvetica, sans-serif;'>
              <a style='text-decoration:none;' href='http://cuidadosamente.com/desarrollo/register/registerValidation.html?code=".$hash."'>
                http://cuidadosamente.com/desarrollo/register/registerValidation.html?code=".$hash."
              </a>
            </td>
          </tr>
      </table>
    </div>
    ";
    
    // Always set content-type when sending HTML email
    $headers = "MIME-Version: 1.0" . "\r\n";
    $headers .= "Content-type:text/html;charset=UTF-8" . "\r\n";
    
    // More headers
    $headers .= 'From: <no-reply@cuidadosamente.com>' . "\r\n";
    
    echo $message;

    echo "<br>";

    //mail($to,$subject,$message,$headers);

    $resp = array('status' => 200, 'data' => 'Message sent');
    echo json_encode($resp);

  } catch (Exception $e) {
    $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
    echo json_encode($catch);
  }
  
?>