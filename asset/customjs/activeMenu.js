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
		}
		catch(x) {
			console.log("activeMenu - ",x.toString());
		}
	}

	this.emptyInfoMenu = function() {
		var deactive = $(".active").data("option");
		
		$("." + deactive).removeClass("active");
		$("." + deactive).removeAttr("style");
		
		$("#info").empty();
		$("#content").empty();
	}
}