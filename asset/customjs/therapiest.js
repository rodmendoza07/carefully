function therapiest() {
    var that = this;

    var objActiveMenu = new activeMenu();

    this.loadProfile = function() {
        $(".therapiest").click(function() {
            objActiveMenu.emptyInfoMenu();
			objActiveMenu.activate("therapiest","");

			$("#content").load("views/client/mytherapiest.html", function(){});
        });
    }
}