function therapiesPast () {
	var that = this;

	var objLanguage = new IdiomaDataTables();
	var objActiveMenu = new activeMenu();

	this.LoadView = function () {
		try {
			$(".sessions").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("sessions","");
	
				$("#info").load("client/therapiesPastA.html", function() {});
	
				$("#content1").load("client/therapiesPast.html", function(){
				
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