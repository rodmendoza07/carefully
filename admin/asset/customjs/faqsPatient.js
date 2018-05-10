function faqsPatient() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadFaqPatient = function() {
        try {
            $(".faqsPatient").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("faqs","faqsPatient");
	
				$("#content1").load("view/faqsPatien.html", function(){
                    try {
                        
                    } catch (x) {
                        console.log("faqsPatient: loadFaqPatient -", x.toString());
                        return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
                    }
                });
			});
        } catch(x) {
            console.log("faqsPatient: loadFaqPatient -", x.toString());
            return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
        }
    }
}