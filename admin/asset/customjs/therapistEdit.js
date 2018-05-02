function therapistEdit() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    var columnas = [
		{ title: 'Nombre', data: 'day'}
		, {title: 'Estatus', data: 'horario'}
	];

    this.getTherapyE = function() {
		var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
			url: "include/a40f4decbdfc66f89706dd0ce8ebf610.php",
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

    this.loadTherapist = function() {
        try {
            $(".therapistEdit").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("therapist","therapistEdit");
	
				$("#content1").load("view/therapistEdit.html", function(){
                    $('#editTable').DataTable({
						"language": objLanguage.espanol,
						"scrollX": true
					});
                });
			});
        } catch(x) {
            console.log("credit: loadCredit -", x.toString());
        }
    }
}