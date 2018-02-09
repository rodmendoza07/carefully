function initHome() {
	var that = this;

	var objActiveMenu = new activeMenu();

	this.LoadView = function() {
		try {
			objActiveMenu.emptyInfoMenu();
			
			$("#info").load("client/cHomeA.html", function() {});

			$("#content1").load("client/cHome.html", function(){
			});
		} catch(x) {
			console.log("initHome: LoadView -", x.toString());
		}
	}
}
