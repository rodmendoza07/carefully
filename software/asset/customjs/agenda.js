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
					$('#agenda').fullCalendar({
                        header: {
                            left: 'prev,next today',
                            center: 'title',
                            right: 'month,agendaWeek,agendaDay'
                        },
                        defaultDate: moment.tz('America/Mexico_City'),
                        defaultView: 'agendaWeek',
                        scrollTime :  "8:00:00",
                        //businessHours: true, // display business hours
                        editable: true,
                        events: [
                            {
                                title: 'Business Lunch',
                                start: '2015-02-03T13:00:00',
                                constraint: 'businessHours'
                            },
                            {
                                title: 'Meeting',
                                start: '2015-02-13T11:00:00',
                                constraint: 'availableForMeeting', // defined below
                                color: '#20C572'
                            },
                            {
                                title: 'Conference',
                                start: '2015-02-18',
                                end: '2015-02-20'
                            },
                            {
                                title: 'Party',
                                start: '2015-02-29T20:00:00'
                            },
            
                            // areas where "Meeting" must be dropped
                            {
                                id: 'availableForMeeting',
                                start: '2015-02-11T10:00:00',
                                end: '2015-02-11T16:00:00',
                                rendering: 'background'
                            },
                            {
                                id: 'availableForMeeting',
                                start: '2015-02-13T10:00:00',
                                end: '2015-02-13T16:00:00',
                                rendering: 'background'
                            },
            
                            // red areas where no events can be dropped
                            {
                                start: '2015-02-24',
                                end: '2015-02-28',
                                overlap: false,
                                rendering: 'background',
                                color: '#FF6656'
                            },
                            {
                                start: '2015-02-06',
                                end: '2015-02-08',
                                overlap: true,
                                rendering: 'background',
                                color: '#FF6656'
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