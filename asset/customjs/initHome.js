function initHome() {
	var that = this;

	var objActiveMenu = new activeMenu();

	this.LoadView = function() {
		objActiveMenu.emptyInfoMenu();
		
		$("#content").load("views/client/cHome.html", function(){});
	}
}
