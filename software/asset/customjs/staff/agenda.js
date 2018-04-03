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
                    console.log('Agenda - ',response.message)
                    return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
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
                    dEnd: that.end
                };
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
            url: "../include/6252f5a0abbad6ecc357bb1de3171348.php",
            dataType: 'JSON',
            data: JSON.stringify(dataPost),
            async: false,
            beforeSend: function() {},
            success: function (response) {
                $("#agendadate").modal('toggle');
                if (response.errno) {
                    console.log('agenda - ',response.message);
                    return toastr.error(response.message, "¡Upps!", 5000);
                } else {
                    $("#agenda").fullCalendar( 'destroy' );
                    that.viewAgenda();
                    return toastr.success('Bloqueo de fechas', '¡Exitóso!', 5000);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                console.log('saveEvents - ', errorThrown);
                console.log('saveEvents - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });
    };

    this.editEvents = function(evento) {
        if (evento.title == 'Chat - Cancelada' || evento.title == 'Videoconferencia - Cancelada') {
            console.log('agenda - Cita cancelada');
            return toastr.error('Las citas canceladas no se pueden reprogramar', "¡Upps!", 5000);
        }

        if(moment().format('YYYY-MM-DD HH:mm:ss') > evento.start.format('YYYY-MM-DD H:mm:ss')){
            console.log('agenda - Evento anterior');
            return toastr.error('Los eventos expirados no se pueden reprogramar', "¡Upps!", 5000);
        }

        $("#reprogramm").modal();
        $("#sessType").empty();
        $("#sessType").append(evento.title);

        if (evento.title == 'No disponible - Fecha bloqueada') {
            $("#reprogsess").css('display', 'none');
            $("#dateIntervaldb").css('display', 'none');
            $("#reprogramOpts").css('display', 'none');
            $("#pacienteNombre").css('display','none');
            $("#pacienteName").empty();
            $("#pacienteName").css('display', 'none')
            $("#debloqOpts").css('display','block');
            $("#debloqD").iCheck("uncheck");
            $("#debloqA").iCheck("uncheck");
            $("#debloqD").on("ifChecked", function(){
                $("#dateIntervaldb").css('display', 'block');
                $("#sincewhendb").val('');
                $("#towhendb").val('');
                $("#saveR").click(function() {
                    var sincedb = $("#sincewhendb").val();
                    var toodb = $("#towhendb").val();
                    that.editBlock(evento.start,sincedb,toodb);
                });
            });
            $("#debloqA").on("ifChecked", function() {
                $("#dateIntervaldb").css('display', 'none');
                $("#saveR").click(function() {
                    that.unblockA(evento.start);
                });
            });
        } else {
            $("#cambioHorario").iCheck('uncheck');
            $("#reprogsess").css('display', 'none');
            $("#debloqOpts").css('display','none');
            $("#reprogramOpts").css('display', 'block');
            var dataPost = {
                dStart: evento.start
            };
            var ajaxN = $.ajax({
                contentType: "application/json; charset=utf-8",
                type: "POST",
                url: "../include/3c33832f1baa148c9263c308db15a243.php",
                dataType: 'JSON',
                data: JSON.stringify(dataPost),
                async: false,
                beforeSend: function() {},
                success: function (response) {
                    if (response.errno) {
                        console.log('getPatientNames - ',response.message);
                        return toastr.error(response.message, "¡Upps!", 5000);
                    } else {
                        $("#pacienteNombre").css('display','block');
                        $("#pacienteName").empty();
                        $("#pacienteName").append(response.data);
                        
                        $("#cambioHorario").on('ifChecked', function() {
                            $("#reprogsess").css('display', 'block');
                            $("#reprogStart").val('');
                            $("#hourStartreprog").val('');
                            $("#saveR").click(function(e) {
                                e.stopPropagation();
                                var nuevafecha = $("#reprogStart").val();
                                var nuevahora = $("#hourStartreprog").val();
                                that.editEventos(evento.start, nuevafecha, nuevahora);
                            });
                        });

                        $("#sesCancelalo").on('ifChecked', function() {
                            $("#reprogsess").css('display', 'none')
                            $("#saveR").click(function() {;
                                that.cancelEventos();
                            });
                        });

                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown){
                    console.log('getPatientNames - ', errorThrown);
                    console.log('getPatientNames - ', XMLHttpRequest);
                    return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                }
            });
        }
    };

    this.editBlock = function(dateold, datenew, endDate) {
        var since = datenew;
        var too =  endDate;
        since = since.split(" ");
        too = too.split(" ");
        var since1 = since[0];
        var since2 = since[1] + ':59';
        var too1 = too[0];
        var too2 = too[1] + ':59';
        since1 =  since1.split("/");
        since1 = since1[2] + '-' + since1[1] + '-' + since1[0];
        since = since1 + ' ' + since2;
        too1 = too1.split("/");
        too1 = too1[2] + '-' + too1[1] + '-' + too1[0];
        too = too1 + ' ' + too2;

        if (moment().format('YYYY-MM-DD HH:mm:ss') > since) {
            console.log('agenda - Fecha menor a la actual');
            return toastr.error('Selecciona una fecha válida', "¡Upps!", 5000);
        }
        if (since > too) {
            console.log('agenda - Fecha inicio mayor a la fecha de termino');
            return toastr.error('La fecha de inicio no puede ser posterior a la fecha de termino.', "¡Upps!", 5000);
        }

        var dataPost = {
            dStart: since,
            dEnd: too,
            dOld: dateold.format('YYYY-MM-DD HH:mm:ss')
        };

        var ajaxRb = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "../include/4be6f695514b3ce01546dd1b38b181ff.php",
            dataType: 'JSON',
            data: JSON.stringify(dataPost),
            async: false,
            beforeSend: function() {},
            success: function (response) {
                $("#reprogramm").modal('toggle');
                if (response.errno) {
                    console.log('editBlock - ',response.message);
                    return toastr.error(response.message, "¡Upps!", 5000);
                } else {
                    $("#agenda").fullCalendar( 'destroy' );
                    that.viewAgenda();
                    return toastr.success('Reprogramación', '¡Exitósa!', 5000);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                console.log('editBlock - ', errorThrown);
                console.log('editBlock - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });

    };

    this.unblockA = function(dateOld) {
        var dataPost = {
            dOld: dateOld.format('YYYY-MM-DD HH:mm:ss')
        };
        
        var ajaxUa = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "../include/0a252b809a182a1f4ca8d10ac5a4edd3.php",
            dataType: 'JSON',
            data: JSON.stringify(dataPost),
            async: false,
            beforeSend: function() {},
            success: function (response) {
                $("#reprogramm").modal('toggle');
                if (response.errno) {
                    console.log('unblockA - ',response.message);
                    return toastr.error(response.message, "¡Upps!", 5000);
                } else {
                    $("#agenda").fullCalendar( 'destroy' );
                    that.viewAgenda();
                    return toastr.success('Desbloqueo de fechas', '¡Exitóso!', 5000);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                console.log('unblockA - ', errorThrown);
                console.log('unblockA - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });
    };

    this.editEventos = function(dateOld, dateNew, hourNew) {
        if (dateNew == '' || hourNew == '') {
            return toastr.error("La fecha y hora de la nueva sesión son requeridos", "¡Upps!", 5000);
        }
        var nuevaDate = dateNew.split("/");
        nuevaDate = nuevaDate[2] + '-' + nuevaDate[1] + '-' + nuevaDate[0];
        hourNew = hourNew + ':59';
        var nuevaFechahora = nuevaDate + ' ' + hourNew;
        if (moment().format('YYYY-MM-DD HH:mm:ss') > nuevaFechahora) {
            return toastr.error("La fecha y hora de la nueva sesión no pueden ser anteriores a la fecha y hora actuales", "¡Upps!", 5000);
        }
        console.log(nuevaDate);
        console.log(hourNew);
        var fechafinalprog = moment(nuevaFechahora).add(50, 'minutes')
        var dataPost = {
            dOld: dateOld.format('YYYY-MM-DD HH:mm:ss'),
            dNew: nuevaFechahora,
            dEnd: fechafinalprog.format('YYYY-MM-DD HH:mm:ss')
        };
        console.log(dataPost);
        var ajaxReprog = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "../include/bbdc22e52d6330e3a97d623faf76290e.php",
            dataType: 'JSON',
            data: JSON.stringify(dataPost),
            async: false,
            beforeSend: function() {},
            success: function (response) {
                if (response.errno) {
                    console.log('editEventos - ',response.message);
                    return toastr.error(response.message, "¡Upps!", 5000);
                } else {
                    $("#agenda").fullCalendar( 'destroy' );
                    that.viewAgenda();
                    return toastr.success('Reprogramación', '¡Exitósa!', 5000);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                console.log('editEventos - ', errorThrown);
                console.log('editEventos - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });
    };

    this.cancelEventos = function() {};

    this.viewAgenda = function() {
        that.getEvents();
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
            selectable: true,
            select: function(start, end, jsEvent, view){
                that.clickEvents(start, end, jsEvent, view)
            },
            eventClick: function(calEvent, jsEvent, view) {
                jsEvent.preventDefault();
                that.editEvents(calEvent);
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