function AppBegin() {
	var that = this;

	try {

		var objHome = new initHome();
		var objAgenda = new agenda();
		var objNewWarnings = new newWarnings();
		var objTherapiesPast = new therapiesPast();
		var objFaqs = new faqs();
		var objFilex = new filex();

		objAgenda.LoadAgenda();
		objHome.LoadView();
		objNewWarnings.reviewWarningsNow();
		objNewWarnings.reviewWarnings();
		objTherapiesPast.LoadView();
		objFaqs.loadfaqs();
		objFilex.loadFilex();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}