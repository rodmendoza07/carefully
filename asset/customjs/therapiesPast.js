function therapiesPast () {
	var that = this;

	this.LoadView = function () {

		$("#content").load("views/client/therapiesPast.html", function(){});

	}

}