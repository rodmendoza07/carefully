function activeMenu () {
	var that = this;

	this.activate = function (id_selector, selectorChild) {
		$("." + id_selector).addClass("active");
		$("." + id_selector).css("background", "#8CC63F");
		$("." + selectorChild).css("display",'block');
		
		$("#mimin-mobile-menu-opener").click();
	}

	this.emptyInfoMenu = function() {
		var deactive = $(".active").data("option");
		
		$("." + deactive).removeClass("active");
		$("." + deactive).removeAttr("style");
		
		$("#info").empty();
		$("#content").empty();
	}
}