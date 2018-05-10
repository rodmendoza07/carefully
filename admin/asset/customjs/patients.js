function patients() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadPatients = function() {
        try {
            $(".patients").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("patients","");
	
				$("#content1").load("view/patients.html", function(){
                    try {
                        
                    } catch (x) {
                        console.log("patients: loadPatients -", x.toString());
                        return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
                    }
                });
			});
        } catch(x) {
            console.log("patients: loadPatients -", x.toString());
            return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
        }
    }
}