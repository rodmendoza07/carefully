function credit() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadCredit = function() {
        try {
            $(".mycredit").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("mycredit","");
	
				$("#content").load("views/client/credit.html", function(){
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