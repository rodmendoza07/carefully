function activeMenu () {
	var that = this;

	this.activate = function (id_selector, selectorChild, optionClick) {
		//console.log($("#" + selector));
		$("#" + id_selector).addClass("active");
		$("#" + id_selector).css("background", "#8CC63F");
		$("#" + selectorChild).css("display",'block');
	}

	this.emptyInfoMenu = function() {
		console.log($(".active").data());
		var deactive = $(".active").data("option");
		console.log(deactive);
		
		$("#" + deactive).removeClass("active");
		$("#" + deactive).removeAttr("style");
		$("#info").empty();

		$("#content").empty();
	}
}