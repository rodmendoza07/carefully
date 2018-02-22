function AppBegin() {
	var that = this;

	try {

		var objHome = new initHome();
		var objAgenda = new agenda();
		var objNewWarnings = new newWarnings();
		var objTherapiesPast = new therapiesPast();
		
		objAgenda.LoadAgenda();
		objHome.LoadView();
		objNewWarnings.reviewWarningsNow();
		objNewWarnings.reviewWarnings();
		objTherapiesPast.LoadView();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}