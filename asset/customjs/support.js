function clientSupport(){
	var that = this;

	var objempty = new activeMenu();

	this.createdTicket = function(){
		$("#tcreated").click(function() {
			objempty.emptyInfoMenu();
			objempty.activate("supportC","tcreated");

			$("#info").load("views/client/ticketCreatedCA.html", function() {});
		});
	}
}