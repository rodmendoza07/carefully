function activeMenu () {
	var that = this;

	this.activate = function (id_selector, selectorChild) {
		console.log(id_selector);
		console.log(selectorChild);

		$("#" + id_selector).addClass("active");
		$("#" + id_selector).css("background", "#8CC63F");
		$("#" + selectorChild).css("display",'block');
	}

	this.emptyInfoMenu = function() {
		var deactive = $(".active").data("option");
		
		$("#" + deactive).removeClass("active");
		$("#" + deactive).removeAttr("style");
		
		$("#info").empty();
		$("#content").empty();
	}
}