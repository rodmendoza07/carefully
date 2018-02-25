function filex() {
    
    var that = this;

	var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    var columnas = [
		{ title: 'Paciente', data: 'uName'}
	];

    this.getPatients = function() {
        var ajaxP = $.ajax({
            contentType: "application/json; charset=utf-8",
			type: "POST",
			url: "../include/d83adae7a44c6c5a4ad66612ce0c8872.php",
			dataType: 'JSON',
			beforeSend: function() {
				$('#loading').modal();
			},
			success: function (response) {
				$('#loading').modal('toggle');
				var datosTabla = response.data;
				$('#patientsTable').DataTable({
					"language": objLanguage.espanol,
					"scrollX": true,
					data: datosTabla,
					columns: columnas
                });
                console.log(response);
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				$('#loading').modal('toggle');
				console.log('MiTerapia - ', errorThrown);
				console.log('MiTerapia - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
        });
    }

    this.loadFilex = function () {
        try {
            $(".filex").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("filex","");
				
				$("#info").load("staff/cHomeA.html", function() {});

				$("#content1").load("staff/filex.html", function(){
                    that.getPatients();
				});
			});
        } catch(x) {
            console.log("filex: loadProfile -", x.toString());
        }
    }
}