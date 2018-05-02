function therapistEdit() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    var columnas = [
        {title: 'ID', data: 'tId'}
		, { title: 'Nombre', data: 'nameC'}
		, {title: 'Estatus', data: 'tStatus'}
	];

    var defs = [
        {targets: 0, width: "5px"}
        , {targets: 0, visible: false}
        , {targets: '_all', className: 'editTh'}
    ];

    this.getTherapyE = function() {
		var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
			url: "include/a40f4decbdfc66f89706dd0ce8ebf610.php",
            dataType: 'JSON',
            async: false,
			beforeSend: function() {
				$('#loading').modal();
			},
			success: function (response) {
                $('#loading').modal('toggle');
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('EditTherapy - ',response.message)
                } else {
                    var datosTabla = response.data;
                    $('#editTable').DataTable({
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
				console.log('EditTherapy - ', errorThrown);
				console.log('EditTherapy - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
		});
	}

    this.getTh = function (tId) {
        var idT = tId;
        var dataPost = {
            tId: idT
        }
        console.log(dataPost)
        var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
            url: "include/51913202dd48d9956bdd11fd7fda91e1.php",
            data: JSON.stringify(dataPost),
            dataType: 'JSON',
            async: false,
			beforeSend: function() {},
			success: function (response) {
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('EditTherapy - ',response.message)
                } else {
                    console.log(response.data);
                    $("#tname").val(response.data[0].tname);
                    $("#tfirstname").val(response.data[0].tfname);
                    $("#tlastname").val(response.data[0].tlname);
                    $("#temail").val(response.data[0].temail);

                    for (var i = 0; i < response.data.length; i++) {
                        response.data[i].tperfil != 0 ? $("#service" + response.data[i].tperfil).prop("checked", true) : $("#service" + response.data[i].tperfil).prop("checked", false);
                    }
                }
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				console.log('EditTherapy - ', errorThrown);
				console.log('EditTherapy - ', XMLHttpRequest);
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
                    that.getTherapyE();

                    $('#editTable tbody').on('click', 'tr', function () {
                        var data = $('#editTable').DataTable().row( this ).data();
                        $("#editThMod").modal();
                        console.log(data);
                        that.getTh(data.tId);
                    } );
                });
                
                
               
			});
        } catch(x) {
            console.log("EditTherapy: loadCredit -", x.toString());
        }
    }
}