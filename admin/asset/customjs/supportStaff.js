function supportStaff() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadSupport = function() {
        try {
            $(".supportC").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("supportC","");
	
				$("#content1").load("view/supportStaff.html", function(){
                    try {
                        
                    } catch (x) {
                        console.log("supportStaff: loadSupport -", x.toString());
                        return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
                    }
                });
			});
        } catch(x) {
            console.log("supportStaff: loadTherapist -", x.toString());
            return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
        }
    }
}