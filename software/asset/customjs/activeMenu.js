function activeMenu () {
	var that = this;

	this.activate = function (id_selector, selectorChild) {
		try {
			$("." + id_selector).addClass("active");
			$("." + id_selector).css("background", "#8CC63F");
			
			if (selectorChild != '') {
				$("." + selectorChild).css("display",'block');
			}
			
			$("#mimin-mobile-menu-opener").click();
		} catch(x) {
			console.log("activeMenu: activate -",x.toString());
		}
	} 
	this.emptyInfoMenu = function() {
		try {
			var deactive = $(".active").data("option");
			
			$("." + deactive).removeClass("active");
			$("." + deactive).removeAttr("style");
			
			$("#info").empty();
			$("#content1").empty();
		} catch(x) {
			console.log("activeMenu: EmptyInfoMenu -", x.toString());
		}
	}
}