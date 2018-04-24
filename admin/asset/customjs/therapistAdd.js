function therapistAdd() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadTherapist = function() {
        try {
            $(".therapistAdd").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("therapist","therapistAdd");
	
				$("#content1").load("view/therapistAdd.html", function(){
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