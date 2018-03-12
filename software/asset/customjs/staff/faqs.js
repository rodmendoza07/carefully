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
                    var pastsectitle = 0;
                    var newsectitle = 0;
					for (var i = 0; i < response.data.length; i++) {
                        newsectitle = response.data[i].cat;
                        if (pastsectitle != newsectitle) {
                            $("#faqContent").append(
                                '<div class="col-md-12" style="padding-top: 10px; padding-bottom: 10px; padding-right: 25px; padding-left:25px">'
                                    + '<h2 class="tittle">' + response.data[i].cdesc + '</h2>'
                                + '</div>'
                                + '<div class="col-md-12 padding-0">'
                                    + '<div class="col-md-12">'
                                        + '<div class="panel box-v4">'
                                            + '<div class="panel-body">'
                                                + '<div class="col-md-12">'
                                                    + '<div class="panel-group" id="accordion_' + response.data[i].cat + '" role="tablist" aria-multiselectable="true"></div>'
                                                + '</div>'
                                            + '</div>'
                                        + '</div>'
                                    + '</div>'
                                + '</div>'
                            );
                            pastsectitle = newsectitle;
                        }
                        if (pastsectitle = newsectitle) {
                            $("#accordion_" + newsectitle).append(
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