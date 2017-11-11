function therapiesPast () {
	var that = this;

	var objLanguage = new IdiomaDataTables();

	this.LoadView = function () {

		$("#sessions").addClass("active");
		$("#sessionMenu").css("display",'block');
		$("#info").load("views/client/therapiesPastA.html", function() {});
		
		$("#content").load("views/client/therapiesPast.html", function(){
			console.log($("#pastTable"));
			$('#pastTable').DataTable({
				"language": objLanguage.espanol,
				"scrollX": true
			});
		});
	}

}