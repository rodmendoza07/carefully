function therapiesPast () {
	var that = this;

	this.LoadView = function () {

		$("#info").load("views/client/therapiesPastA.html", function() {});
		$("#content").load("views/client/therapiesPast.html", function(){});

	}

}