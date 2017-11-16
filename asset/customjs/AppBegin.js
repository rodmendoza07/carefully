function AppBegin() {
	var that = this;

	var objHome = new initHome();
	var objprofile = new myProfile();
	var objTherapiesPast = new therapiesPast();
	var objClientSupport = new clientSupport();

	try {
		objHome.LoadView();
		objprofile.loadProfile();
		objTherapiesPast.LoadView();
		objClientSupport.createdTicket();
	} catch(x) {
		console.log("Error en - ", x.toString());
	}

}