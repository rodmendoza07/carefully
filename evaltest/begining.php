<?php
  try {


  } catch (Exception $e) {
    $catch = array('status' => 500, 'errno' => 1001, 'message' => $e);
    echo json_encode($catch);
  }
?>

<!DOCTYPE html>
<html lang="es">
<head>
	
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
    <title>[CuidadosaMENTE]</title>
 
  <!-- start: Css -->
    <link rel="stylesheet" type="text/css" href="asset/css/bootstrap.min.css">

    <!-- plugins -->
    <link rel="stylesheet" type="text/css" href="asset/css/plugins/font-awesome.min.css"/>
    <link rel="stylesheet" type="text/css" href="asset/css/plugins/simple-line-icons.css"/>
    <link rel="stylesheet" type="text/css" href="asset/css/plugins/animate.min.css"/>
    <link rel="stylesheet" type="text/css" href="asset/css/plugins/fullcalendar.min.css"/>
    <link rel="stylesheet" type="text/css" href="asset/css/plugins/datatables.bootstrap.min.css"/>
    <!-- <link href="https://fonts.googleapis.com/css?family=Raleway" rel="stylesheet"> -->
    <link href="asset/css/style.css" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="asset/css/plugins/icheck/skins/flat/green.css"/>
    <link rel="stylesheet" href="asset/css/toastr.min.css"/>
	<!-- end: Css -->
  
  <!--Custom css-->
    <link rel="stylesheet" type="text/css" href="asset/css/customcss.css">

	<link rel="shortcut icon" href="asset/img/favico.jpeg">
    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  <style>
    body {
      background: url('resource/bkg1.png');
    }
  </style>
  </head>
  
 <body id="mimin" class="dashboard">

      <div class="container-fluid">

          <!-- start: content -->
            <div id="content">
              <div class="row">
                <div class="col-md-2 col-xs-8" style="padding-top: 30px;">
                  <img src="resource/logo.png" class="img-responsive">
                </div>
              </div>
                <div class="row" style="margin-top: 10%">
                    <div class="col-md-12 col-xs-12">
                      <h1 class="text-center titleBold" style="color:white;">Test de evaluación</h1>
                      <div class="col-md-12 text-center" style="padding-bottom:25px;">
                          <p class="col-md-6 col-md-offset-3 col-xs-12" style="font-size: 18px;">
                              La información que se proporciona en el test es meramente
                              orientativa y tendrá como finalidad obtener información
                              básica de tu problemática para derivarte con el terapeuta
                              más adecuado para ti. Te agradecemos responder de la
                              manera más veraz posible.
                          </p>
                      </div>
                      <!-- <div class="row" style="margin-top: 25px;"> -->
                          <div class="col-md-2 col-md-offset-5 col-xs-12">
                            <button class="btn btn-default btn-pill btn-block">
                                <span class="buttonReef">INICIAR</span>
                            </button>
                          </div>
                      <!-- </div> -->
                    </div>
                </div>
            <div class="modal fade" id="loading" role="dialog">
              <div class="modal-dialog modal-sm">
                 <div class="modal-content">
                    <div class="modal-body text-center" style="color: #8cc63f;">
                       <div class="row">
                          <div class="col-md-12">
                             <h1>
                                <i class="fa fa-spinner fa-spin" aria-hidden="true"></i>
                             </h1>
                          </div>
                       </div>
                    </div>
                 </div>
              </div>
           </div>
          <!-- /.modal -->
          <!-- end: content -->
          
      </div>
    <!-- start: Javascript -->
    <script src="asset/js/jquery.min.js"></script>
    <script src="asset/js/jquery.ui.min.js"></script>
    <script src="asset/js/bootstrap.min.js"></script>
   
    <!-- plugins -->
    <script src="asset/js/plugins/moment.min.js"></script>
    <script src="asset/js/plugins/moment-timezone-with-data.min.js"></script>
    <script src="asset/js/plugins/jquery.nicescroll.js"></script>
    <script src="asset/js/plugins/icheck.min.js"></script>
    <script src="asset/js/plugins/jquery.validate.min.js"></script>
    <script src="asset/js/toastr.min.js"></script>
    <script src="asset/js/main.js"></script>

     <script type="text/javascript"> 
      $(document).ready(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_flat-green', radioClass:
            'iradio_flat-green'
        });
      });
    </script>

  <!-- end: Javascript -->
  </body>
</html>