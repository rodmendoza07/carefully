function myProfile(){
	var that = this;

	var objActiveMenu = new activeMenu();

	this.loadProfile = function() {
		$(".myprof").click(function() {
			objActiveMenu.emptyInfoMenu();
			objActiveMenu.activate("myprof","");

			$("#content").load("views/client/myprofile.html", function(){});
		});
	}
}