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
					$('#supportTable').DataTable({
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

	this.sendTicket =  function() {
		var dataPost = {
			ssubjcet: $("#ssubject").val(), 
			smessage: $("#smessage").val()
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
					that.getTickets();
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
	
				$("#info").load("client/ticketCreatedCA.html", function() {});
	
				$("#content1").load("client/ticketCreatedC.html", function() {
					that.getTickets();

					$("#createT").click(function() {
						that.sendTicket();
					});
				});
			});
		}catch(x) {
			console.log("clientSupport: createdTicket -", x.toString());
		}
	}
}