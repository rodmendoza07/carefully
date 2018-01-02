function myProfile(){
	var that = this;

	var objActiveMenu = new activeMenu();

	this.loadProfile = function() {
		try {
			$(".myprof").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("myprof","");
				
				$("#content1").load("views/client/myprofile.html", function(){
					console.log($("body").height());
					var altura = $("body").height()
					console.log(altura);
					$("#menu-left").addAttr("height");
				});
			});
		} catch(x) {
			console.log("myProfile: loadProfile -", x.toString());
		}
	}
}