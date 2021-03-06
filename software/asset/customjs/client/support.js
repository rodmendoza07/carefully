function clientSupport(){
	var that = this;

	var objLanguage = new IdiomaDataTables();
	var objempty = new activeMenu();

	var columnas = [
		{title: 'Folio', data: 'folio'}
		, {title: 'Fecha', data: 'dateS'}
		, {title: 'Hora', data: 'hours'}
		, {title: 'Asunto', data: 'asunto'}
		, {title: 'Estado', data: 'estado'}
	];

	var columnasDefs = [
		{targets: 0, width:'text-right'}
		, {targets: 1, width:'text-center'}
		, {targets: 2, width:'text-center'}
	];


	this.getTickets = function() {
		var ajaxT = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
			url: "../include/92e3abee65008a777b2698ce7625f72a.php",
			dataType: 'JSON',
			beforeSend: function() {
				$('#loading').modal();
			},
			success: function (response) {
				$('#loading').modal('toggle');
				if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('clientSupport - ',response.message)
                } else {
					var datosTabla = response.data;
					var tableSupport = '<table class="table table-bordered dtables" id="supportTable" width="100%"></table>'
					$("#tableContent").append(tableSupport);
					$("#supportTable").DataTable({
						"language": objLanguage.espanol,
						"scrollX": true,
						data: datosTabla,
						columns: columnas,
						columnDefs: columnasDefs
					});
				}
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				$('#loading').modal('toggle');
				console.log('clientSupport - ', errorThrown);
				console.log('clientSupport - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
		});
	}

	this.sendTicket =  function(ssubjcet, smessage) {
		var _ssubjcet = ssubjcet;
		var _smessage = smessage;

		var dataPost = {
			ssubjcet: _ssubjcet, 
			smessage: _smessage
		};

		var ajaxst = $.ajax({
			contentType: "application/json; charset=utf-8",
			type: "POST",
			url: "../include/7412383484b16664171838df957b025a.php",
			data: JSON.stringify(dataPost),
			dataType: 'JSON',
			beforeSend: function() {
			},
			success: function (response) {
				if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('clientSupport - ',response.message)
                } else {
					$("#tableContent").empty();
					that.getTickets();
					$("#supportAdv").modal();
				}
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				console.log('clientSupport - ', errorThrown);
				console.log('clientSupport - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
		});
	}

	this.createdTicket = function(){
		try {
			$(".supportC").click(function() {
				objempty.emptyInfoMenu();
				objempty.activate("supportC","");
	
				$("#info").load("client/ticketCreatedCA.html", function() {
					$("#formNumber").validate({
						rules: {
							phone: {
								required: true,
								number: true
							}
						},
						messages: {
							phone: {
								required: "<span class='text-danger'>Campo obligatorio</span>",
								number: "<span class='text-danger'>Ingresa un número válido</span>"
							}
						}
					});

					$("#sendPhone").click(function() {
						if ($("#formNumber").valid()) {
							$("#sendPhone").click(function() {
								if ($("#formNumber").valid()) {
									that.sendTicket('Solicitud de llamada Soporte Técnico', 'Llamar al número ' + $("#number").val());
									$("#number").val('');
								}
							});
						}
					});
				});
	
				$("#content1").load("client/ticketCreatedC.html", function() {
					that.getTickets();

					$("#createT").click(function() {
						that.sendTicket($("#ssubject").val(), $("#smessage").val());
						$("#ssubject").val('');
						$("#smessage").val('');
					});

					$("#cancelT").click(function() {
						$("#ssubject").val('');
						$("#smessage").val('');
					});
				});
			});
		}catch(x) {
			console.log("clientSupport: createdTicket -", x.toString());
		}
	}
}