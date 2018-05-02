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

    this.table;
    this.service1 = "";
    this.service2 = "";
    this.service3 = "";
    this.service4 = "";

    this.cleanform = function() {
        $("#tname").val("");
        $("#tfirstname").val("");
        $("#tlastname").val("");
        $("#temail").val("");
        $('#service1').prop('checked', false);
        $('#service2').prop('checked', false);
        $('#service3').prop('checked', false);
        $('#service4').prop('checked', false);
        $("#optionsEdit").empty();
    }

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
                    that.table = $('#editTable').DataTable({
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
                    that.cleanform();
                    $("#tname").val(response.data[0].tname);
                    $("#tfirstname").val(response.data[0].tfname);
                    $("#tlastname").val(response.data[0].tlname);
                    $("#temail").val(response.data[0].temail);

                    for (var i = 0; i < response.data.length; i++) {
                        response.data[i].tperfil != 0 ? $("#service" + response.data[i].tperfil).prop("checked", true) : $("#service" + response.data[i].tperfil).prop("checked", false);
                        if (response.data[i].tperfil == 1) {
                            that.service1 = response.data[i].tperfil + ',';
                        }
                        if (response.data[i].tperfil == 2) {
                            that.service2 = response.data[i].tperfil + ',';
                        }
                        if (response.data[i].tperfil == 3) {
                            that.service3 = response.data[i].tperfil + ',';
                        }
                        if (response.data[i].tperfil == 4) {
                            that.service4 = response.data[i].tperfil + ',';
                        }
                    }

                    $("#optionsEdit").append(
                        '<button type="button" id="banUser" class="btn btn-warning btn-pill" data-id="' + idT + '">'
                            + '<i class="fa fa-ban"></i>&nbsp;&nbsp;Inhabilitar Terapeuta'
                        + '</button>'
                        + '<button type="button" id="saveThInfo" class="btn btn-primary btn-pill" data-id="' + idT + '">'
                            + '<i class="fa fa-save"></i>&nbsp;&nbsp;Guardar'
                        + '</button>'
                    );
                }
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				console.log('EditTherapy - ', errorThrown);
				console.log('EditTherapy - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
		});
    }

    this.banTh = function(tId) {
        var idT = tId;
        var dataPost = {
            tId: idT
        }
        var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
            url: "include/1b447dd62ddd0220003dec9518677854.php",
            data: JSON.stringify(dataPost),
            dataType: 'JSON',
            async: false,
			beforeSend: function() {},
			success: function (response) {
                $("#editThMod").modal('toggle');
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('EditTherapy - ',response.message)
                }
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				console.log('EditTherapy - ', errorThrown);
				console.log('EditTherapy - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
		});
    }

    this.editTherapiest = function(tId) {
        var idT = tId;
        

        $("#service1").change(function() {
            if (this.checked) {
                that.service1 = $("#service1").val() + ",";
            } else {
                that.service1 = "";
            }
        });
        $("#service2").change(function() {
            if (this.checked) {
                that.service2 = $("#service2").val() + ",";
            } else {
                that.service2 = "";
            }
        });
        $("#service3").change(function() {
            if (this.checked) {
                that.service3 = $("#service3").val() + ",";
            } else {
                that.service3 = "";
            }
        });
        $("#service4").change(function() {
            if (this.checked) {
                that.service4 = $("#service4").val() + ",";
            } else {
                that.service4 = "";
            }
        });

        var servicios = "";
        servicios = that.service1 + that.service2 + that.service3 + that.service4;
        
        if (servicios == "") {
            return toastr.warning("Asigna por lo menos un servicio.", "¡Atención!", 5000);
        }
        servicios = servicios.split(",");
        servicios.pop();
        servicios = servicios.join();

        var dataPost = {
            tId: idT,
            name: $("#tname").val(),
            fname: $("#tfirstname").val(),
            lname: $("#tlastname").val(),
            service: servicios
        }
        var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
            url: "include/a5ac8bf9b07f60c7153a4e8220a957f8.php",
            data: JSON.stringify(dataPost),
            dataType: 'JSON',
            async: false,
			beforeSend: function() {},
			success: function (response) {
                $("#editThMod").modal('toggle');
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('EditTherapy - ',response.message)
                } else {
                    toastr.success("Modificación Terapeuta: " + $("#tname").val(), "¡Exitóso!", 5000);
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
                        var idData = data.tId;
                        $("#editThMod").modal();
                        that.getTh(idData);
                        $("#banUser").click(function(e) {
                            var idDatas = e.target.id;
                            that.banTh($("#" + idDatas).data("id"));
                            that.table.destroy();
                            that.getTherapyE();
                        });
                        $("#saveThInfo").click(function(e) {
                            var idDatas = e.target.id;
                            that.editTherapiest($("#" + idDatas).data("id"));
                            that.table.destroy();
                            that.getTherapyE();
                        });
                    } );
                });
                
                
               
			});
        } catch(x) {
            console.log("EditTherapy: loadCredit -", x.toString());
        }
    }
}