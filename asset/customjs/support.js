function clientSupport(){
	var that = this;

	var objempty = new activeMenu();

	this.createdTicket = function(){
		try {
			$(".tcreated").click(function() {
				objempty.emptyInfoMenu();
				objempty.activate("supportC","tcreated");
	
				$("#info").load("views/client/ticketCreatedCA.html", function() {});
	
				$("#content").load("views/client/ticketCreatedC.html", function() {});
			});
		}catch(x) {
			console.log("clientSupport: createdTicket -", x.toString());
		}
	}
}