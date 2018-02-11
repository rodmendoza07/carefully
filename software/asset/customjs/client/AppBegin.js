function AppBegin() {
	var that = this;

	try {
		// var v2945ed38d275bf8c99e15df1edfcea82 = new f2945ed38d275bf8c99e15df1edfcea82();
		
		// if (v2945ed38d275bf8c99e15df1edfcea82.fff2945ed38d275bf8c99e15df1edfcea82()) {	
			var objHome = new initHome();
			var objTherapiest = new therapiest();
			var objprofile = new myProfile();
			var objCredit = new credit();
			var objTherapiesPast = new therapiesPast();
			var objClientSupport = new clientSupport();
			var objAgenda = new agenda();
			var objNewWarnings = new newWarnings();
			objAgenda.LoadAgenda();
			objHome.LoadView();
			objTherapiest.loadProfile();
			objprofile.loadProfile();
			objCredit.loadCredit();
			objTherapiesPast.LoadView();
			objClientSupport.createdTicket();
			objNewWarnings.reviewWarningsNow();
			objNewWarnings.reviewWarnings();
		// } else {
		// 	window.location = '../register/login.html';
		// }

	} catch(x) {
		console.log("Error en AppBegin -", x.toString());
	}

}