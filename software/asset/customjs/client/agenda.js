function agenda() {
	var that = this;
	var objActiveMenu = new activeMenu();

    this.events = [];
    this.start;
    this.end;
    this.comm;
    this.viewAgenda = function() {
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
            select: function(start, end, jsEvent, view) {
                //$('.myCheckbox').prop('checked', false);
                console.log(moment(start).minutes());
                var dayD = moment(start);
                var startD = moment(start);
                var endD = moment(end).add(20,'minutes');
                var doctorD = "Sara Beneyto";
                var textD = "¿Estás seguro que quieres agendar una cita con <span style='font-weight:bold;'>"
                    + doctorD + "</span> el día <span style='font-weight:bold;'>" + dayD.format("DD/MM/YYYY") 
                    + "</span> de <span style='font-weight:bold;'>" + startD.format("hh:mm:ss a") 
                    + "</span> a <span style='font-weight:bold;'>" + endD.format("hh:mm:ss a") + "</span>?";
                $("#agendadate").modal();
                $("#datetitle").text("Nueva sesión");
                $("#dateText").empty();
                $("#dateText").append(textD);

                $("#createSess").click(function() {
                    that.start = '';
                    that.end = '';
                    console.log(that.start);
                    console.log(that.end);
                    console.log(newEvent);
                    that.start = dayD.format('YYYY-MM-DD HH:mm:ss');
                    that.end = endD.format('YYYY-MM-DD HH:mm:ss');
                    var dataPost = {
                        dStart: that.start, 
                        dEnd: that.end,
                        dCom: $('input[name=sessOpt]:checked', '#selectOpt').val()
                    };
                    var titleEvent = '';
                    switch ($('input[name=sessOpt]:checked', '#selectOpt').val()) {
                        case '1':
                            titleEvent = 'Chat - Enviada';
                            break;
                        case '2':
                            titleEvent = 'Videoconferencia - Enviada';
                            break;
                        default:
                            break;
                    }
                    
                    var newEvent = {
                        title: titleEvent,
                        start: that.start,
                        end: that.end,
                        color: '#29ABE2'
                    }
                    console.log(dataPost);
                    console.log(newEvent);
                    //$("#agenda").fullCalendar('renderEvent', newEvent);
                    //$("#agenda").fullCalendar('refetchEvents');
                    //onsole.log($("#agenda").fullCalendar('refetchEvents'));
                    var ajaxF = $.ajax({
                        contentType: "application/json; charset=utf-8",
                        type: "POST",
                        url: "../include/ca3e4974a8639906d8099f07c44b54ee.php",
                        dataType: 'JSON',
                        data: JSON.stringify(dataPost),
                        async: false,
                        beforeSend: function() {
                           // $('#loading').modal();
                        },
                        success: function (response) {
                           // $("#agenda").fullCalendar( 'destroy' );
                            //$("#agenda").fullCalendar('render');
                            //$('#loading').modal('toggle');
                            //$("#agendadate").modal('toggle');
                            console.log(response);
                            //$("#agenda").fullCalendar('renderEvents', that.events);
                            //that.LoadAgenda();
                            if (response.errno) {   
                                //alert("que pedo");
                                console.log('Agenda - ',response.message)
                                return toastr.error(response.message, "¡Upps!", 5000);
                            } 
                            location.reload();
                            //else {
                            //     successs = true;
                            //     return successs;
                            //     //$('#loading').modal('toggle');
                            //     //$("#agenda").empty();
                            //     // $("#agenda").fullCalendar('renderEvent', newEvent);
                            //     // //$('#agenda').fullCalendar('destroy');
                            //     // //$("#agenda").fullCalendar('rerenderEvents');
                            //     // console.log(newEvent);
                            //     // console.log($("#agenda"));
                            //     //that.viewAgenda();
                                
                            //     //$("#agendadate").modal('toggle');
                            //     that.events = [];
                            // }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown){
                            //$('#loading').modal('toggle');
                            console.log('getAllDates - ', errorThrown);
                            console.log('getAllDates - ', XMLHttpRequest);
                            return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                        }
                    });
                });
            },
            eventClick: function(calEvent, jsEvent, view) {

                // alert('Event: ' + calEvent.title);
                // alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);
                // alert('View: ' + view.name);
            },
            events: that.events
        });
        console.log(that.events);
    }
    this.getEvents = function() {
        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/9bc8f51edd581007d1ceae746a1d7802.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
                $('#loading').modal();
            },
            success: function (response) {
                $('#loading').modal('toggle');
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
    this.saveEvents = function() {
        
    };
	this.LoadAgenda = function() {
		try {
			$(".agenda").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("agenda","");
	
				//$("#info").load("views/client/ticketCreatedCA.html", function() {});
	
				$("#content1").load("client/agenda.html", function() {
                    $("#frontAgenda").datepicker();
                    that.getEvents();
                    that.viewAgenda();
                    
                    $("#cancelDc").click(function(event){
                        $("#chatC").iCheck('check');
                        $("#videoC").iCheck('uncheck');
                    });
                    that.events = [];
				});
			});
		} catch(x) {
			console.log("initHome: LoadView -", x.toString());
		}
	}
}