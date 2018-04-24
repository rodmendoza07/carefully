<?php
    $tr = true;
    echo $tr;
    try {
        include '../software/include/class/class.getInfoUser.php';
        session_start();
    
        if (!isset($_SESSION['9987435b7dbef543b786efd81d1b3dc9']) && empty($_SESSION['9987435b7dbef543b786efd81d1b3dc9'])) {    
            header('location: ../../register/login.html');
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

<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>[CuidadosaMENTE]</title>
    <!-- start: Css -->
    <link rel="stylesheet" type="text/css" href="./asset/css/bootstrap.min.css">
    <!-- plugins -->
    <link rel="stylesheet" type="text/css" href="./asset/css/plugins/font-awesome.min.css"/>
    <link rel="stylesheet" type="text/css" href="./asset/css/plugins/simple-line-icons.css"/>
    <link rel="stylesheet" type="text/css" href="./asset/css/plugins/animate.min.css"/>
    <link rel="stylesheet" type="text/css" href="./asset/css/plugins/fullcalendar.min.css"/>
    <link rel="stylesheet" type="text/css" href="./asset/css/plugins/datatables.bootstrap.min.css"/>
    <link rel="stylesheet" type="text/css" href="./asset/css/plugins/icheck/skins/flat/green.css"/>
    <link rel="stylesheet" href="./asset/css/toastr.min.css"/>
    <link href="https://fonts.googleapis.com/css?family=Raleway" rel="stylesheet">
    <link href="./asset/css/style.css" rel="stylesheet">
    <!-- end: Css -->
    <!--Custom css-->
    <link rel="stylesheet" type="text/css" href="./asset/css/customcss.css">
    <link rel="stylesheet" type="text/css" href="./asset/css/plugins/bootstrap-material-datetimepicker.css"/>
    <link rel="shortcut icon" href="./asset/img/favico.jpeg">
    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body id="mimin" class="dashboard" onload="AppBegin();">
      <!-- start: Header -->
    <nav class="navbar navbar-default header navbar-fixed-top">
      <div class="col-md-12 nav-wrapper">
        <div class="navbar-header" style="width:100%;">
          <div class="opener-left-menu is-open">
            <span class="top"></span>
            <span class="middle"></span>
            <span class="bottom"></span>
          </div>
          <a href="./" class="navbar-brand" style="margin-left: 0px; margin-top: -8px;"> 
            <img class="img-responsive" src="./asset/img/logo-white1.png">
          </a>
          <ul class="nav navbar-nav navbar-right user-nav">
            <li class="dropdown avatar-dropdown" style="margin-top: 15px; margin-right:10px;" id="newWarnings">
              <i class="fa fa-bell" style="font-size:25px;" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true"></i>
              <span class="label label-warning totalWarnings" id="totalWarningsBell" style="margin-left:-8px;"></span>
            </li>
            <li class="dropdown avatar-dropdown">
              <img src="./asset/img/avatar.jpg" class="img-circle avatar" alt="user name" data-toggle="dropdown" aria-haspopup="true" aria-expanded="true"/>
              <ul class="dropdown-menu user-dropdown">
                <li><a><span class="icons icon-emotsmile"></span>&nbsp;&nbsp;Mi perfil</a></li>
                <li><a href="../include/74c4e9f90722e101af64290a61bce1de.php"><span class="icons icon-logout"></span>&nbsp;&nbsp;Cerrar sesión</a></li>
              </ul>
            </li>

            <li class="user-name"><span><?php echo $cName; ?></span></li>
          </ul>
        </div>
      </div>
    </nav>
    <!-- end: Header -->

    <div class="container-fluid mimin-wrapper">
      <!-- start:Left Menu -->
      <div id="left-menu">
        <div class="sub-left-menu scroll" id="menu-left">
          <ul class="nav nav-list" id="mDynamics">
            <li class="time text-center">
              <h3 class="animated fadeInLeft"></h3>
              <p class="animated fadeInRight">CDMX (GMT-6)</p>
            </li>
            <li class="ripple filex menu-hover" data-option="filex">
              <a class="tree-toggle nav-header">
                Pacientes
              </a>
            </li>
            <li class="ripple therapist menu-hover" data-option="therapist">
              <a class="tree-toggle nav-header">
                Terapeutas
              </a>
              <ul class="nav nav-list tree" data-optionChild="sessionMenu" id="sessionMenu">
                <li><a class="therapistAdd heightAuto">Nuevo</a></li>
                <li><a class="therapistEdit heightAuto">Editar</a></li>
              </ul>
            </li>
            <li class="ripple supportC menu-hover" data-option="supportC">
              <a class="tree-toggle nav-header">
                Soporte
              </a>
            </li>
            <li class="ripple faqs menu-hover" data-option="faqs">
              <a class="tree-toggle nav-header">
                FAQ's 
              </a>
            </li>
            <li>
              <div class="col-md-11" id="info"></div>
            </li>
          </ul>
        </div>
      </div>
      <!-- end: Left Menu -->
      <!-- start: content -->
      <div id="content">
      <div class="col-md-12 padding-0" id="content1">
          <div class="col-md-12 eldiv portada">
            <h1 style="font-size: 45px; padding-top:25px;">BIENVENID@</h1>
          </div>
        </div>
      </div>
      <!-- end: content -->
    </div>

    <!-- start: Mobile -->
    <div id="mimin-mobile" class="reverse">
      <div class="mimin-mobile-menu-list">
          <div class="col-md-12 sub-mimin-mobile-menu-list animated fadeInLeft">
              <ul class="nav nav-list">
                  <li class="ripple sessions heightAuto" data-option="sessions">
                    <a class="tree-toggle nav-header">
                      Pacientes
                    </a>
                  </li>
                  <li class="ripple therapist heightAuto" data-option="therapist" style="height: auto;">
                    <a class="tree-toggle nav-header">
                      Terapeutas
                    </a>
                    <ul class="nav nav-list tree" data-optionChild="sessionMenu" id="sessionMenu">
                      <li><a class="therapistAdd heightAuto">Nuevo</a></li>
                      <li><a class="therapistEdit heightAuto">Editar</a></li>
                    </ul>
                  </li>
                  <li class="ripple supportC heightAuto" data-option="supportC" style="height: auto;">
                    <a class="tree-toggle nav-header">
                      Soporte
                    </a>
                  </li>
                  <li class="ripple filex heightAuto" data-option="filex" style="height: auto;">
                    <a class="tree-toggle nav-header">
                      FAQ's
                    </a>
                  </li>
                </ul>
          </div>
      </div>       
    </div>
    <button id="mimin-mobile-menu-opener" class="animated rubberBand btn btn-circle movilBoton">
      <span class="fa fa-bars"></span>
    </button>
    <!-- end: Mobile -->

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
    <div class="modal fade modal-v1" id="mnewWarnings" role="dialog">
      <div class="modal-dialog modal-lg">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div class="modal-body" id="detailWarning">
              <div class="row">
                <div class="col-md-12">
                  <div class="col-md-12" id="bodyWarnings"></div>
                  <table class='table table-striped table-bordered'>
                    <thead id="theadWarnings">
                    </thead>
                    <tbody id="warningsBody"></tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
      </div>
    </div>
    <!-- start: Javascript -->
    <script src="./asset/js/jquery.min.js"></script>
    <script src="./asset/js/jquery.ui.min.js"></script>
    <script src="./asset/js/bootstrap.min.js"></script>
    <!-- plugins -->
    <script src="./asset/js/plugins/moment.min.js"></script>
    <script src="./asset/js/plugins/moment-timezone-with-data.min.js"></script>
    <script src="./asset/js/plugins/fullcalendar.min.js"></script>
    <script src="./asset/js/plugins/jquery.nicescroll.js"></script>
    <script src="./asset/js/plugins/jquery.vmap.min.js"></script>
    <script src="./asset/js/plugins/maps/jquery.vmap.world.js"></script>
    <script src="./asset/js/plugins/jquery.vmap.sampledata.js"></script>
    <script src="./asset/js/plugins/chart.min.js"></script>
    <script src="./asset/js/plugins/jquery.datatables.min.js"></script>
    <script src="./asset/js/plugins/datatables.bootstrap.min.js"></script>
    <script src="./asset/js/toastr.min.js"></script>
    <script src="./asset/js/plugins/icheck.min.js"></script>
    <script src="./asset/js/plugins/jquery.validate.min.js"></script>
    <script src="./asset/js/plugins/bootstrap-material-datetimepicker.js"></script>
    <!-- custom -->
    <script src="./asset/js/main.js"></script>
    <script src="./asset/customjs/AppBegin.js"></script>
    <script src="./asset/customjs/activeMenu.js"></script>
    <script src="./asset/customjs/dataLanguage.js"></script>
    <script src="./asset/customjs/therapistAdd.js"></script>
    <script src="./asset/customjs/therapistEdit.js"></script>
  <!-- end: Javascript -->
  </body>
</html>
