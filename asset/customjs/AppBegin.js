function AppBegin() {
	var that = this;

	var objTherapiesPast = new therapiesPast();
	var objClientSupport = new clientSupport();

	try {
		objTherapiesPast.LoadView();
		objClientSupport.createdTicket();
	} catch(x) {
		console.log("Error en - ", x);
	}

}