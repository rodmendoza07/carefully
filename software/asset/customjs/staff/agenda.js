function agenda() {
	var that = this;
	var objActiveMenu = new activeMenu();

    this.events = [];
    this.start;
    this.end;
    this.comm;
    this.currentDate;
    this.counter = false;

    this.getEvents = function() {
        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/eb18f524d4cc2f06d791dd918ffbf597.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
                $('#loading').modal();
            },
            success: function (response) {
                $('#loading').modal('hide');
                // $("#loading").on('hidden.bs.modal', function () {
                //     $(this).data('bs.modal', null);
                // });
                if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('Agenda - ',response.message)
                } else {
                    for (var index = 0; index < response.data.length; index++) {
                        var eventosR = {
                            title: response.data[index].titleDesc + ' - ' + response.data[index].statusDesc,
                            start: response.data[index].start,
                            end: response.data[index].end,
                            color: response.data[index].color
                        };
                        that.events.push(eventosR);
                    }
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                $('#loading').modal('toggle');
                toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                console.log('getAllDates - ', errorThrown);
                console.log('getAllDates - ', XMLHttpRequest);
            }
        });
    }
    this.pmodal = function(dayD,startD, endD, doctorD) {
        var textD = "<span class='care-warning-modal'>Estarás como<span style='font-weight:bold;'>"
            + " NO DISPONIBLE</span></span>";
        $("#agendadate").modal();
        $("#datetitle").text("Fechas no disponibles");
        $("#dateText").empty();
        $("#dateText").append(textD);
    }
    this.clickEvents = function(start, end, jsEvent, view){
        jsEvent.preventDefault();
        var dayD = moment(start);
        var startD = moment(start);
        var endD = moment(end).add(20,'minutes');
        var doctorD = "Sara Beneyto";
        that.start = '';
        that.end = '';
        that.currentDate = '';
        that.start = dayD.format('YYYY-MM-DD HH:mm:ss');
        that.end = endD.format('YYYY-MM-DD HH:mm:ss');
        that.currentDate = moment().format('YYYY-MM-DD HH:mm:ss');
        if (that.currentDate > that.start) {
            console.log('agenda - Fecha menor a la actual');
            return toastr.error('Selecciona una fecha válida', "¡Upps!", 5000);
        }

        if (!that.counter) {
            
            that.pmodal(dayD,startD, endD, doctorD);

            $("#createSess").click(function(event) {
                that.counter = true;
                event.preventDefault();
                var since = $("#sincewhen").val();
                var too =  $("#towhen").val();
                since = since.split(" ");
                too = too.split(" ");
                var since1 = since[0];
                var since2 = since[1] + ':00';
                var too1 = too[0];
                var too2 = too[1] + ':00';
                since1 =  since1.split("/");
                since1 = since1[2] + '-' + since1[1] + '-' + since1[0];
                since = since1 + ' ' + since2;
                too1 = too1.split("/");
                too1 = too1[2] + '-' + too1[1] + '-' + too1[0];
                too = too1 + ' ' + too2;
                that.start = since;
                that.end = too;
                var dataPost = {
                    dStart: that.start, 
                    dEnd: that.end,
                    dCom: 3
                };
                console.log(dataPost);
                // // var titleEvent = '';
                // // switch ($('input[name=sessOpt]:checked', '#selectOpt').val()) {
                // //     case '1':
                // //         titleEvent = 'Chat - Enviada';
                // //         break;
                // //     case '2':
                // //         titleEvent = 'Videoconferencia - Enviada';
                // //         break;
                // //     default:
                // //         break;
                // // }
                that.saveEvents(dataPost, event);
            });
            } else {
                $("#agendadate").on('hidden.bs.modal', function () {
                    $(this).data('bs.modal', null);
                });
                that.pmodal(dayD,startD, endD, doctorD);
            }
    }
    this.saveEvents = function(dataPost, event) {
        event.preventDefault();
        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "../include/ca3e4974a8639906d8099f07c44b54ee.php",
            dataType: 'JSON',
            data: JSON.stringify(dataPost),
            async: false,
            beforeSend: function() {},
            success: function (response) {
                $("#agendadate").modal('toggle');
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('agenda - ',response.message);
                } else {
                    $("#agenda").fullCalendar( 'destroy' );
                    that.viewAgenda();
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                console.log('getAllDates - ', errorThrown);
                console.log('getAllDates - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });
    };

    this.editEvents = function(titleEvent) {
        if (titleEvent == 'Chat - Cancelada' || titleEvent == 'Videoconferencia - Cancelada') {
            console.log('agenda - Cita cancelada');
            return toastr.error('Las citas canceladas no se pueden reprogramar', "¡Upps!", 5000);
        }


    };

    this.viewAgenda = function() {
        that.getEvents();
        console.log(that.events);
        var successs = false;
        $('#agenda').fullCalendar({
            height : screen.height,
            width  : screen.width,
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'month,agendaWeek,agendaDay'
            },
            defaultDate: moment.tz('America/Mexico_City'),
            defaultView: 'agendaWeek',
            scrollTime :  "8:00:00",
            businessHours: {
                dow: [1,2,3,4,5],
                start: '8:00',
                end: '20:00'
            },
            selectable: true,
            select: function(start, end, jsEvent, view){
                that.clickEvents(start, end, jsEvent, view)
            },
            eventClick: function(calEvent, jsEvent, view) {
                jsEvent.preventDefault();
                that.editEvents(calEvent.title);
            },
            events: that.events
        });
        that.events = [];
    }
    
    this.agendaOperations = function() {
        objActiveMenu.emptyInfoMenu();
        objActiveMenu.activate("agenda","");

        $("#info").load("staff/agendaA.html", function() {});

        $("#content1").load("staff/agenda.html", function() {
            $("#frontAgenda").datepicker();

            that.viewAgenda();
            
            $("#cancelDc").click(function(event){
                event.preventDefault();
                $("#chatC").iCheck('check');
                $("#videoC").iCheck('uncheck');
            });
            that.events = [];
        });
    }

	this.reloadAgenda = function() {
        setInterval(function(){ 
            that.agendaOperations();
        }, 30000);
    } 

	this.LoadAgenda = function() {
		try {
			$(".agenda").click(function() {
                that.agendaOperations();
                //that.reloadAgenda();
            });
		} catch(x) {
			console.log("initHome: LoadView -", x.toString());
		}
	}
}