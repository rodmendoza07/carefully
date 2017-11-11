function AppBegin() {
	var that = this;

	var objTherapiesPast = new therapiesPast();

	try {
		objTherapiesPast.LoadView();
	} catch(x) {
		console.log("Error en - ", x);
	}

}