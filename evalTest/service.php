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
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/font-awesome.min.css" />
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/simple-line-icons.css" />
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/animate.min.css" />
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/fullcalendar.min.css" />
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/datatables.bootstrap.min.css" />
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/ionrangeslider/ion.rangeSlider.css" />
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/ionrangeslider/ion.rangeSlider.skinHTML5.css" />
	<link href="https://fonts.googleapis.com/css?family=Raleway" rel="stylesheet">
	<link href="asset/css/style.css" rel="stylesheet">
	<link rel="stylesheet" type="text/css" href="asset/css/plugins/icheck/skins/flat/green.css" />
	<link rel="stylesheet" href="asset/css/toastr.min.css" />
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
	<!-- start: Header -->
	<nav class="navbar navbar-default header navbar-fixed-top">
		<div class="col-md-12 nav-wrapper">
			<div class="navbar-header" style="width:100%;">
				<a href="index.html" class="navbar-brand" style="margin-left: 0px; margin-top: -8px;">
				<img class="img-responsive" src="asset/img/logo-white1.png">
				</a>
				<ul class="nav navbar-nav navbar-right user-nav">
					<li class="dropdown avatar-dropdown">
						<a href="login.html" style="margin-top: -12px; margin-right: -15px;">
							<img src="asset/img/user_lock.png" class="img-circle avatar" alt="user name" data-toggle="dropdown" aria-haspopup="true"
							aria-expanded="true" />
						</a>
					</li>
					<li class="user-name">
						<span>
							<a href="login.html">Iniciar sesión</a>
						</span>
					</li>
				</ul>
			</div>
		</div>
	</nav>
	<!-- end: Header -->

	<div class="container-fluid">

	<!-- start: content -->
		<div id="content" style="padding-top:15px;">
			<div class="row" style="margin-top: 25px;">
				<div class="col-md-12 padding-0">
					<div class="col-md-12">
						<h1 style="font-weight:bolder; color:white;">SERVICIO</h1>
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
				<div class="col-md-8 col-md-offset-4 text-center">
					<div class="form-group">
                        <h2>¿En cuál de nuestros servicios estás interesado?</h2>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-8 col-md-offset-4">
					
				</div>
            </div>
            <div class="row" style="margin-top:25px;">
				<div class="col-md-8 col-md-offset-4 text-center">
					<button class="btn btn-default btn-pill">
						<span style="font-weight: bold; color: #000"><i class="fa fa-chevron-left" aria-hidden="true"></i>&nbsp;&nbsp;ATRÁS</span>
                    </button>
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
	<script src="asset/js/plugins/ion.rangeSlider.min.js"></script>
	<script src="asset/js/main.js"></script>

	<script type="text/javascript">
	$(document).ready(function () {
		$('input').iCheck({
			checkboxClass: 'icheckbox_flat-green',
			radioClass: 'iradio_flat-green'
		});
		$("#range1").ionRangeSlider({
			grid: true,
			min: 0,
			max: 100,
			from: 0,
			onFinish: function (data) {
				console.log(data.from);
				$("#edadDat").empty();
				$("#edadDat").append(data.from + ' Años.')
			},
		});
	});
	</script>

	<!-- end: Javascript -->
</body>
</html>