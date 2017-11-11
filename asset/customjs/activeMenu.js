function activeMenu () {
	var that = this;

	this.activate = function (id_selector, selectorChild) {
		//console.log($("#" + selector));
		$("#" + id_selector).addClass("active");
		$("#" + id_selector).css("background", "#8CC63F");
		$("#" + selectorChild).css("display",'block');
	}

	this.emptyInfoMenu = function() {
		$("#info").empty();
	}
}