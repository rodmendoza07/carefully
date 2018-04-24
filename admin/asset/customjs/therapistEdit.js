function therapistEdit() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadTherapist = function() {
        try {
            $(".therapistEdit").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("therapist","therapistEdit");
	
				$("#content1").load("view/therapistEdit.html", function(){
                    $('#creditTable').DataTable({
						"language": objLanguage.espanol,
						"scrollX": true
					});
                });
			});
        } catch(x) {
            console.log("credit: loadCredit -", x.toString());
        }
    }
}