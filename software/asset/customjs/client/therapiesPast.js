function therapiesPast () {
	var that = this;

	var objLanguage = new IdiomaDataTables();
	var objActiveMenu = new activeMenu();

	var columnas = [
		{ title: 'Fecha', data: 'day'}
		, {title: 'Horario', data: 'horario'}
		, {title: 'Terapeuta', data: 'names'}
		, {title: 'Estatus', data: 'status'}
	];

	this.getTherapyE = function() {
		var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
			url: "../include/a663f70f9b93269df13b0da56fc99a48.php",
			dataType: 'JSON',
			beforeSend: function() {
				$('#loading').modal();
			},
			success: function (response) {
				$('#loading').modal('toggle');
				var datosTabla = response.data;
				$('#pastTable').DataTable({
					"language": objLanguage.espanol,
					"scrollX": true,
					data: datosTabla,
					columns: columnas
				});
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				$('#loading').modal('toggle');
				console.log('MiTerapia - ', errorThrown);
				console.log('MiTerapia - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
		});
	}

	this.LoadView = function () {
		try {
			$(".sessions").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("sessions","");
				objActiveMenu.stopAgenda("sessions")

				$("#info").load("client/therapiesPastA.html", function() {});
	
				$("#content1").load("client/therapiesPast.html", function(){
					that.getTherapyE();
				});
			});
		} catch(x) {
			console.log("therapiePast: LoadView -", x.toString());
		} 
	}

}