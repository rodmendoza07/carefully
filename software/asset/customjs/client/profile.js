function myProfile(){
	var that = this;

	var objActiveMenu = new activeMenu();

	this.getProfInfo = function() {

	}
	
	this.loadProfile = function() {
		try {
			$(".myprof").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("myprof","");
				
				$("#info").load("client/cHomeA.html", function() {});

				$("#content1").load("client/myprofile.html", function(){
					
					that.getProfInfo();
					
					$("#ePersonal").click(function() {

					});

					$("#ePaditional").click(function() {

					});
				});
			});
		} catch(x) {
			console.log("myProfile: loadProfile -", x.toString());
		}
	}
}