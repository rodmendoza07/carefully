function faqsTherapy() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadFaqTherapy = function() {
        try {
            $(".faqsTherapy").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("faqs","faqsTherapy");
	
				$("#content1").load("view/faqsTherapy.html", function(){
                    try {
                        
                    } catch (x) {
                        console.log("faqsTherapy: loadFaqTherapy -", x.toString());
                        return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
                    }
                });
			});
        } catch(x) {
            console.log("faqsTherapy: loadFaqTherapy -", x.toString());
            return toastr.error("Algo ha ido mal, por favor comunicate con Soporte Técnico", "¡Atención!", 5000);
        }
    }
}