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
	<!-- <style>
		body {
			background: url('resource/bkg2.png');
			background-size: cover;
		}
  	</style> -->
</head>

<body id="mimin" class="dashboard">
	<div class="container-fluid">

	<!-- start: content -->
		<div id="content">
			<div class="row">
				<div class="col-md-12 padding-0">
					<div class="col-md-12">
						<h1 class="titleBold" style="color:white;">EDAD</h1>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12">
					<h4 class="subtitleBold">Instrucciones</h4>
					<h4 class="subtitleBold">Desliza el controlador para determinar tu edad.</h4>
				</div>
			</div>
			<div class="row" style="margin-top: 7%;">
				<div class="col-md-6 col-md-offset-5">
					<div class="form-group">
						<input type="text" id="range1" />
					</div>
				</div>
			</div>
			<div class="row" style="margin-top:25px;">
				<div class="col-md-6 col-md-offset-5 text-center">
					<h2 id="edadDat" class="subtitleBold" style="font-size: 35px;">0 AÑOS.</h2>
				</div>
			</div>
			<div class="row" style="margin-top:15px;">
				<div class="col-md-6 col-md-offset-5">
					<button class="btn btn-default btn-pill pull-left col-md-3 col-xs-12" style="margin-top: 10px;">
						<span class="buttonReef"><i class="fa fa-chevron-left" aria-hidden="true"></i>&nbsp;&nbsp;ATRÁS</span>
					</button>
					<button class="btn btn-default btn-pill pull-right col-md-3 col-xs-12" style="margin-top: 10px;">
						<span class="buttonReef">SIGUIENTE&nbsp;&nbsp;<i class="fa fa-chevron-right" aria-hidden="true"></i></span>
					</button>
				</div>
				<div class="col-md-3 col-xs-3" style="margin-top:-10%; position:absolute;">
                	<img class="img-responsive" src="resource/n2.png">
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
				$("#edadDat").append(data.from + ' AÑOS.')
			},
		});
	});
	</script>

	<!-- end: Javascript -->
</body>

</html>