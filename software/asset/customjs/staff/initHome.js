function initHome() {
	var that = this;

	this.LoadView = function() {
		try {
			var noClick = true;
			$("#info").load("staff/cHomeA.html", function() {});
		} catch(x) {
			console.log("initHome: LoadView -", x.toString());
		}
	}
}