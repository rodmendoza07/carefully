function credit() {
    var that = this;

    var objActiveMenu = new activeMenu();

    this.loadCredit = function() {
        try {
            $(".mycredit").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("mycredit","");
	
				$("#content").load("views/client/credit.html", function(){});
			});
        } catch(x) {
            console.log("credit: loadCredit -", x.toString());
        }
    }
}