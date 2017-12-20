function therapiesPast () {
	var that = this;

	var objLanguage = new IdiomaDataTables();
	var objActiveMenu = new activeMenu();

	this.LoadView = function () {
		try {
			$(".tpast").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("sessions","sessionMenu");
	
				$("#info").load("views/client/therapiesPastA.html", function() {});
	
				$("#content").load("views/client/therapiesPast.html", function(){
				
					$('#pastTable').DataTable({
						"language": objLanguage.espanol,
						"scrollX": true
					});
				});
			});
		} catch(x) {
			console.log("therapiePast: LoadView -", x.toString());
		} 
	}

}