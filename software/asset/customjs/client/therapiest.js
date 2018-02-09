function therapiest() {
    var that = this;

    var objActiveMenu = new activeMenu();

    this.loadProfile = function() {
        try {
            $(".therapiest").click(function() {
                objActiveMenu.emptyInfoMenu();
                objActiveMenu.activate("therapiest","");
    
                $("#content1").load("client/mytherapiest.html", function(){});
            });
        } catch(x) {
            console.log("therapiest: loadProfile -", x.toString());
        }
    }
}