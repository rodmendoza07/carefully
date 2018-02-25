function faqs() {
    var that = this;

    var objActiveMenu = new activeMenu();
    
    this.getFaqs = function() {
        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/f91e7bc0c6dd90b991d1e792e20d255b.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
            },
            success: function (response) {
				console.log(response);
                if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('GetProfileUsr - ',response.message)
                } else {
					for (var i = 0; i < response.data.length; i++) {
						$("#accordion").append(
                            '<div class="panel panel-default">'
                                + '<div class="panel-heading" role="tab" id="heading_' + response.data[i].qId + '">'
                                    + '<h4 class="panel-title">'
                                            + '<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse_' + response.data[i].qId + '" aria-expanded="false" aria-controls="collapse_' + response.data[i].qId + '">'
                                                + '<h4 class="tittle">' + response.data[i].qQuestion + '</h4>'
                                            + '</a>'
                                    + '</h4>'
                                + '</div>'
                                + '<div id="collapse_' + response.data[i].qId + '" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading_' + response.data[i].qId + '">'
                                    + '<div class="panel-body" style="font-weight: bold; font-size: 14px;">' + response.data[i].aAnswer + '</div>'
                                + '</div>'
                            + '</div>'
                        );
					}
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                console.log('GetProfile - ', errorThrown);
                console.log('GetProfile - ', XMLHttpRequest);
            }
        });
    }

    this.loadfaqs = function(){
        try {
            $(".faqs").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("faqs","");
				
				$("#info").load("staff/cHomeA.html", function() {});

				$("#content1").load("staff/faqs.html", function(){
                    that.getFaqs();
				});
			});
        } catch(x) {
            console.log("faqs: loadProfile -", x.toString());
        }
    }
}