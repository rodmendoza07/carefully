function AppBegin() {
	var that = this;

	try {

		var objHome = new initHome();
		var objAgenda = new agenda();
		var objNewWarnings = new newWarnings();
		var objTherapiesPast = new therapiesPast();
		var objFaqs = new faqs();
		
		objAgenda.LoadAgenda();
		objHome.LoadView();
		objNewWarnings.reviewWarningsNow();
		objNewWarnings.reviewWarnings();
		objTherapiesPast.LoadView();
		objFaqs.loadfaqs();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}