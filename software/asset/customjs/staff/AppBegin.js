function AppBegin() {
	var that = this;

	try {

		var objHome = new initHome();
		var objAgenda = new agenda();
		var objNewWarnings = new newWarnings();
		
		objAgenda.LoadAgenda();
		objHome.LoadView();
		objNewWarnings.reviewWarningsNow();
		objNewWarnings.reviewWarnings();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}