function AppBegin() {
	var that = this;

	try {

		var objHome = new initHome();
		var objTherapiest = new therapiest();
		var objprofile = new myProfile();
		var objCredit = new credit();
		var objTherapiesPast = new therapiesPast();
		var objClientSupport = new clientSupport();

		objHome.LoadView();
		objTherapiest.loadProfile();
		objprofile.loadProfile();
		objCredit.loadCredit();
		objTherapiesPast.LoadView();
		objClientSupport.createdTicket();
	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}