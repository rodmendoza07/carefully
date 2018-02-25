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
					var historial;
					console.log(response);
					$("#usrName").empty();
					$("#usrGender").empty();
					$("#usrNation").empty();
					$("#usrAge").empty();
					$("#usrBirthDate").empty();
					$("#usrCs").empty();					
					$("#usrName").val(response.name);
					that.getCivilState(response.idCs);
					that.getGender(response.idGender);
					that.getNationality(response.idNac);
					$("#usrAge").text(response.age);	
					$("#usrBirthDate").text(moment(response.birthdate).format('DD/MM/YYYY'));
					$("#usrEmail").text(response.email);
					$("#usrTcontact").val(response.phoneContact);
					response.ps == "" ? historial = 'No existen datos en la bitácora' : historial = response.ps;
					console.log(response.ps);
					console.log(historial);
					$("#histhosp").text(historial);
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
	
	this.getCivilState = function(actualState) {
		var ajaxC = $.ajax({
			contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/266e14860b87694ba80b6bbfd5fb1f8d.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
            },
            success: function (response) {
                if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('GetProfileUsr - ',response.message)
                } else {
					for (var i = 0; i < response.data.length; i++) {
						var option = document.createElement('option');
						option.value = response.data[i].ceId;
						option.innerHTML = response.data[i].ceDesc;
						$("#usrCs").append(option);
					}
					if (actualState == 0) {
						$("#usrCs").val(5);
					} else {
						$("#usrCs").val(actualState);
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

	this.getGender = function(gender) {
		var ajaxG = $.ajax({
			contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/ed682c707feff8bc04e5d207cb152d90.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
            },
            success: function (response) {
                if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('GetProfileUsr - ',response.message)
                } else {
					for (var i = 0; i < response.data.length; i++) {
						var option = document.createElement('option');
						option.value = response.data[i].gId;
						option.innerHTML = response.data[i].gDesc;
						$("#usrGender").append(option);
					}
					if (gender == 0) {
						$("#usrGender").val(3);
					} else {
						$("#usrGender").val(gender);
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

	this.getNationality = function(nation) {
		console.log(nation);
		var ajaxG = $.ajax({
			contentType: "application/json; charset=utf-8",
            type: "GET",
            url: "../include/330dad7ca7c59c5aeeaf93ab0c19e159.php",
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
						var option = document.createElement('option');
						option.value = response.data[i].nId;
						option.innerHTML = response.data[i].nDesc;
						$("#usrNation").append(option);
					}
					if (nation == 0) {
					} else {
						$("#usrNation").val(nation);
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