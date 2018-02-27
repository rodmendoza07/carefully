function filexD () {
    var that = this;
    
    var objActiveMenu = new activeMenu();

    this.loadFilexD = function() {
        try {
            $(".editar").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("filex","");

				$("#info").load("staff/cHomeA.html", function() {});

				$("#content1").load("staff/filexD.html", function(){
				});
			});
        } catch (x) {
            console.log("filex: loadProfile -", x.toString());
        }
    }
}