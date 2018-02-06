function clientSupport(){
	var that = this;

	var objLanguage = new IdiomaDataTables();
	var objempty = new activeMenu();

	this.createdTicket = function(){
		try {
			$(".supportC").click(function() {
				objempty.emptyInfoMenu();
				objempty.activate("supportC","");
	
				$("#info").load("views/client/ticketCreatedCA.html", function() {});
	
				$("#content1").load("views/client/ticketCreatedC.html", function() {
					$('#supportTable').DataTable({
						"language": objLanguage.espanol,
						"scrollX": true
					});
				});
			});
		}catch(x) {
			console.log("clientSupport: createdTicket -", x.toString());
		}
	}
}