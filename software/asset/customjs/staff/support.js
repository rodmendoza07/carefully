function clientSupport(){
	var that = this;

	var objLanguage = new IdiomaDataTables();
	var objempty = new activeMenu();

	this.createdTicket = function(){
		try {
			$(".supportC").click(function() {
				objempty.emptyInfoMenu();
				objempty.activate("supportC","");
	
				$("#info").load("staff/ticketCreatedCA.html", function() {});
	
				$("#content1").load("staff/ticketCreatedC.html", function() {
					$('#supportTable').DataTable({
						"language": objLanguage.espanol,
						"scrollX": true
					});
				});
			});
		}catch(x) {
			console.log("staffSupport: createdTicket -", x.toString());
		}
	}
}