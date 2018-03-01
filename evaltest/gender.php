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
    <link href="https://fonts.googleapis.com/css?family=Raleway" rel="stylesheet">
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
  </head>

 <body id="mimin" class="dashboard">

      <div class="container-fluid">

          <!-- start: content -->
            <div id="content">
              <div class="row">
                <div class="col-md-12 padding-0">
                  <div class="col-md-12">
                    <h1 style="font-weight:bolder; color:white;">GÉNERO</h1>
                  </div>
                </div>
              </div>
              <div class="row">
                <div class="col-md-12">
                  <h4>Instrucciones</h4>
                  <h4>Haz click en la opción que corresponda.</h4>
                </div>
              </div>
              <div class="row" style="margin-top: 25px;">
                <div class="col-md-4 col-md-offset-4 text-center">
                  <a href="#" style="color: white !important;"><i class="fa fa-female" aria-hidden="true" style="font-size:220px;"></i></a>&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="#" style="color: white !important;"><i class="fa fa-male" aria-hidden="true" style="font-size:220px;"></i></a>
                </div>
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