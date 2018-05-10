function supportStaff() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    var columnas = [
        {title: 'id', data: 'folioId'}
        , {title: 'Folio', data: 'folio'}
		, { title: 'Fecha', data: 'dateS'}
        , {title: 'Hora', data: 'hours'}
        , {title: 'Asunto', data: 'asunto'}
        , {title: 'Status', data: 'estado'}
        , {title: 'Nombre', data:'nombre'}
        , {title: 'Cuenta de usuraio', data: 'userAccount'}
        , {title: 'Tipo de usuario', data: 'typePerson'}
	];

    var defs = [
        {targets: 0, visible: false}
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
                console.log(response);
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('supportStaff - ',response.message)
                } else {
                    var datosTabla = response.data;
                    that.table = $('#supportTable').DataTable({
                        "language": objLanguage.espanol,
                        "scrollX": true,
                        data: datosTabla,
                        columns: columnas,
                        columnDefs: defs
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

    this.getSupportDetail = function(folioId, typeReport) {
        var dataPost = {
            folioId: folioId
            , typeReport: typeReport
        };
        var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
            url: "include/b013f53ea236fbca8bd6e5a4cefbe137.php",
            data: JSON.stringify(dataPost),
            dataType: 'JSON',
            async: false,
			beforeSend: function() {},
			success: function (response) {
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('supportStaff - ',response.message)
                } else {
                    console.log(response);
                    $("#usrName").val(response.nombre);
                    $("#usrNick").val(response.userAccount);
                    $("#usrSubject").val(response.asunto);
                    $("#commentReport").val(response.comment);
                    $("#ticketFolio").text(response.folio);
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
                            var idData = data.folioId;
                            var typeReport = data.typeReport;
                            $("#supportDetail").modal();
                            console.log(data);
                            that.getSupportDetail(idData, typeReport);
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