function initHome() {
	var that = this;

	var objActiveMenu = new activeMenu();

	this.LoadView = function() {
		try {
			objActiveMenu.emptyInfoMenu();
			
			$("#info").load("staff/staffViews/sHomeA.html", function() {});

			$("#content1").load("staff/staffViews/sHome.html", function(){
			});
		} catch(x) {
			console.log("initHome: LoadView -", x.toString());
		}
	}
}