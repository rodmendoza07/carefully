function myProfile(){
	var that = this;

	var objActiveMenu = new activeMenu();

	this.getProfInfo = function() {
		var ajaxF = $.ajax({
			contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/48a7402a3518a14719277c0531bdd8c2.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
                $('#loading').modal();
            },
            success: function (response) {
                $('#loading').modal('hide');
                if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('GetProfileUsr - ',response.message)
                } else {
					$("#usrName").empty();
					$("#usrGender").empty();
					$("#usrNation").empty();
					$("#usrAge").empty();
					$("#usrBirthDate").empty();
					$("#usrCs").empty();					
					$("#usrName").val(response.name);
					$("#usrGender").val(response.gender);
					$("#usrNation").text(response.nation);
					$("#usrAge").text(response.age);	
					$("#usrBirthDate").text(moment(response.birthdate).format('DD/MM/YYYY'));
					$("#usrCs").text(response.civilState);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                $('#loading').modal('toggle');
                toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                console.log('GetProfile - ', errorThrown);
                console.log('GetProfile - ', XMLHttpRequest);
            }
		});
	}
	
	this.getCivilState = function() {
		var ajaxC = $.ajax({
			contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/48a7402a3518a14719277c0531bdd8c2.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
                $('#loading').modal();
            },
            success: function (response) {
                $('#loading').modal('hide');
                if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('GetProfileUsr - ',response.message)
                } else {
					console.log(response);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                $('#loading').modal('toggle');
                toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                console.log('GetProfile - ', errorThrown);
                console.log('GetProfile - ', XMLHttpRequest);
            }
		});
	}

	this.loadProfile = function() {
		try {
			$(".myprof").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("myprof","");
				
				$("#info").load("client/cHomeA.html", function() {});

				$("#content1").load("client/myprofile.html", function(){
					
					that.getProfInfo();
					
					$("#ePersonal").click(function() {
						
					});

					$("#ePaditional").click(function() {

					});
				});
			});
		} catch(x) {
			console.log("myProfile: loadProfile -", x.toString());
		}
	}
}