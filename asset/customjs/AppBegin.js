function AppBegin() {
	var that = this;

	var objHome = new initHome();
	var objTherapiest = new therapiest();
	var objprofile = new myProfile();
	var objTherapiesPast = new therapiesPast();
	var objClientSupport = new clientSupport();

	try {
		objHome.LoadView();
		objTherapiest.loadProfile();
		objprofile.loadProfile();
		objTherapiesPast.LoadView();
		objClientSupport.createdTicket();
	} catch(x) {
		console.log("Error en - ", x.toString());
	}

}