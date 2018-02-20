function AppBegin() {
	var that = this;

	try {

		var objAgenda = new agenda();
		var objNewWarnings = new newWarnings();
		
		objAgenda.LoadAgenda();
		objNewWarnings.reviewWarningsNow();
		objNewWarnings.reviewWarnings();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}