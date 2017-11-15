function clientSupport(){
	var that = this;

	var objempty = new activeMenu();

	this.createdTicket = function(){
		$(".tcreated").click(function() {
			console.log("camara");
			objempty.emptyInfoMenu();
			objempty.activate("supportC","tcreated");

			$("#info").load("views/client/ticketCreatedCA.html", function() {});

			$("#content").load("views/client/ticketCreatedC.html", function() {});
		});
	}
}