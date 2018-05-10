function AppBegin() {
	var that = this;

	try {
		var objTherapistAdd = new therapistAdd();
		var objTherapistEdit = new therapistEdit();
		var objSupport = new supportStaff();
		var objFaqsP = new faqsPatient();
		var objFaqsT = new faqsTherapy();
		var objPatient = new patients();

		objTherapistAdd.loadTherapist();
		objTherapistEdit.loadTherapist();
		objSupport.loadSupport();
		objFaqsP.loadFaqPatient();
		objFaqsT.loadFaqTherapy();
		objPatient.loadPatients();

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}