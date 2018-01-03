function initHome() {
	var that = this;

	var objActiveMenu = new activeMenu();

	this.LoadView = function() {
		try {
			objActiveMenu.emptyInfoMenu();
			
			$("#info").load("views/client/cHomeA.html", function() {});

			$("#content1").load("views/client/cHome.html", function(){
			});
		} catch(x) {
			console.log("initHome: LoadView -", x.toString());
		}
	}
}
