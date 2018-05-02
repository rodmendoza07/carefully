function AppBegin() {
	var that = this;

	try {
		var objTherapistAdd = new therapistAdd();
		var objTherapistEdit = new therapistEdit();
		var objSupport = new supportStaff();

		objTherapistAdd.loadTherapist();
		objTherapistEdit.loadTherapist();
		//objSupport.loadSupport();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}