function AppBegin() {
	var that = this;

	try {
		var objTherapistAdd = new therapistAdd();
		var objTherapistEdit = new therapistEdit();

		objTherapistAdd.loadTherapist();
		objTherapistEdit.loadTherapist();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}