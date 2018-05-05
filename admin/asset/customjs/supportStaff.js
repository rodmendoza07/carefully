function supportStaff() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    var columnas = [
        {title: 'Folio', data: 'folio'}
		, { title: 'Fecha', data: 'dateS'}
        , {title: 'Hora', data: 'hours'}
        , {title: 'Asunto', data: 'asunto'}
        , {title: 'Status', data: 'estado'}
        , {title: 'Nombre', data:'nombre'}
        , {title: 'Cuenta de usuraio', data: 'userAccount'}
        , {title: 'Tipo de usuario', data: 'typePerson'}
	];

    this.table;

    this.getAllTickets = function() {
        var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
			url: "include/6dca921522f38fd44f3c332360279c8f.php",
            dataType: 'JSON',
            async: false,
			beforeSend: function() {
				$('#loading').modal();
			},
			success: function (response) {
                $('#loading').modal('toggle');
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('supportStaff - ',response.message)
                } else {
                    var datosTabla = response.data;
                    that.table = $('#supportTable').DataTable({
                        "language": objLanguage.espanol,
                        "scrollX": true,
                        data: datosTabla,
                        columns: columnas
                    });
                }
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				$('#loading').modal('toggle');
				console.log('supportStaff - ', errorThrown);
				console.log('supportStaff - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
		});
    }

    this.getSupportDetail = function() {
        
    }

    this.loadSupport = function() {
        try {
            $(".supportC").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("supportC","");
	
				$("#content1").load("view/supportStaff.html", function(){
                    try {
                        that.getAllTickets();
                        $('#supportTable tbody').on('click', 'tr', function () {
                            var data = $('#supportTable').DataTable().row( this ).data();
                            var idData = data.tId;
                            $("#supportDetail").modal();
                            
                        } );
                    } catch (x) {
                        console.log("supportStaff: loadSupport -", x.toString());
                        return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
                    }
                });
			});
        } catch(x) {
            console.log("supportStaff: loadTherapist -", x.toString());
            return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
        }
    }
}