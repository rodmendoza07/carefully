function agenda() {
	var that = this;

	var objActiveMenu = new activeMenu();

	this.LoadAgenda = function() {
		try {
			$(".agenda").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("agenda","");
	
				//$("#info").load("views/client/ticketCreatedCA.html", function() {});
	
				$("#content1").load("views/client/agenda.html", function() {
                    $("#frontAgenda").datepicker();
					$('#agenda').fullCalendar({
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
                            start: '7:59',
                            end: '20:00'
                        },
                        selectable: true,
                        select: function(start, end, jsEvent, view) {
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
                            $("#dayD").text(dayD.format('DD/MM/YYYY'));
                            $("#startD").text(startD.format('hh:mm:ss a'));
                            $("#endD").text(endD.format('hh:mm:ss a'));
                            $("#dateText").empty();
                            $("#dateText").append(textD);
                            $("#optionD").text();
                            var allDay = !start.hasTime && !end.hasTime;
                            alert(["Event Start date: " + moment(start).format(),
                                   "Event End date: " + moment(end).add(20,'minutes').format(),
                                   "AllDay: " + allDay].join("\n"));
                        },
                        eventClick: function(calEvent, jsEvent, view) {

                            alert('Event: ' + calEvent.title);
                            alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);
                            alert('View: ' + view.name);
                        },
                        events: [
                            {
                                title: 'Business Lunch',
                                start: '2018-01-03T13:00:00',
                                //constraint: 'businessHours'
                            },
                            {
                                title: 'Meeting',
                                start: '2018-01-13T11:00:00',
                                //constraint: 'availableForMeeting', // defined below
                                //color: '#20C572'
                            },
                            {
                                title: 'Conference',
                                start: '2018-01-18',
                                end: '2015-01-20'
                            },
                            {
                                title: 'Party',
                                start: '2018-01-20T20:00:00'
                            }
                        ]
                    });
				});
			});
		} catch(x) {
			console.log("initHome: LoadView -", x.toString());
		}
	}
}