function agenda() {
	var that = this;
	var objActiveMenu = new activeMenu();

    this.events = [];
    this.start;
    this.end;
    this.comm;
    this.counter = false;

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
    this.pmodal = function(dayD,startD, endD, doctorD) {
        var textD = "¿Estás seguro que quieres agendar una cita con <span style='font-weight:bold;'>"
            + doctorD + "</span> el día <span style='font-weight:bold;'>" + dayD.format("DD/MM/YYYY") 
            + "</span> de <span style='font-weight:bold;'>" + startD.format("hh:mm:ss a") 
            + "</span> a <span style='font-weight:bold;'>" + endD.format("hh:mm:ss a") + "</span>?";
        $("#agendadate").modal();
        $("#datetitle").text("Nueva sesión");
        $("#dateText").empty();
        $("#dateText").append(textD);
    }
    this.clickEvents = function(start, end, jsEvent, view){
        
        jsEvent.preventDefault();
        console.log(that.counter);
        var dayD = moment(start);
        var startD = moment(start);
        var endD = moment(end).add(20,'minutes');
        var doctorD = "Sara Beneyto";

        if (!that.counter) {
            
            
            that.pmodal(dayD,startD, endD, doctorD);

            $("#createSess").click(function(event) {
                that.counter = true;
                event.preventDefault();
                that.start = '';
                that.end = '';
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
                that.saveEvents(dataPost, event);
            });
            } else {
                console.log();
                $("#agendadate").empty();
                that.pmodal(dayD,startD, endD, doctorD);
            }
         //$('.myCheckbox').prop('checked', false);
         
    }
    this.saveEvents = function(dataPost, event) {
        console.log(event);
        event.preventDefault();
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
                $("#agendadate").modal('toggle');
                console.log(response);
                $("#agenda").fullCalendar( 'destroy' );
                that.viewAgenda();
                //$('#calendar').fullCalendar('addEventSource',events);
                //$("#agenda").fullCalendar('renderEvent', newEvent);
                //that.LoadAgenda();
                // if (response.errno) {   
                //     console.log('Agenda - ',response.message)
                //     return toastr.error(response.message, "¡Upps!", 5000);
                // } 
                
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                //$('#loading').modal('toggle');
                console.log('getAllDates - ', errorThrown);
                console.log('getAllDates - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });
    };


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

                // alert('Event: ' + calEvent.title);
                // alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);
                // alert('View: ' + view.name);
            },
            events: that.events
        });
        console.log(that.events);
        that.events = [];
    }
    
	this.LoadAgenda = function() {
		try {
			$(".agenda").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("agenda","");
	
				//$("#info").load("views/client/ticketCreatedCA.html", function() {});
	
				$("#content1").load("client/agenda.html", function(event) {
                    $("#frontAgenda").datepicker();

                    that.viewAgenda();
                    
                    $("#cancelDc").click(function(event){
                        event.preventDefault();
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