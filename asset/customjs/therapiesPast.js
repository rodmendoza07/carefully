function therapiesPast () {
	var that = this;

	var objLanguage = new IdiomaDataTables();
	var objActiveMenu = new activeMenu();

	this.LoadView = function () {

		$("#tpast").click(function() {
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
	}

}