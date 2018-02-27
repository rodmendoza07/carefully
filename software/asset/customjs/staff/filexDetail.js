function filexD () {
    var that = this;
    
    var objActiveMenu = new activeMenu();

    this.getBitacora = function(patient) {
        var dataPost = {pId: patient};
        var ajaxGb = $.ajax({
            contentType: "application/json; charset=utf-8",
			type: "POST",
            url: "../include/49f5278d047c798f80a56ed15544bc8b.php",
            data: JSON.stringify(dataPost),
			dataType: 'JSON',
			beforeSend: function() {
				$('#loading').modal();
			},
			success: function (response) {
				$('#loading').modal('toggle');
				if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('filexD - ',response.message)
                } else {
                    $("#histFam").empty();
                    $("#dinFam").empty();
                    $("#mc").empty();
                    $("#hpa").empty();
                    $("#am").empty();
                    $("#psi").empty();
                    $("#trauma").empty();
                    $("#ps").empty();
                    $("#usrName").empty();

                    $("#usrName").text(response.name);
                    $("#histFam").val(response.df);
                    $("#dinFam").val(response.hf);
                    $("#mc").val(response.mc);
                    $("#hpa").val(response.hpa);
                    $("#am").val(response.am);
                    $("#psi").val(response.psi);
                    $("#trauma").val(response.trauma);
                    $("#ps").val(response.ps);
                }
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				$('#loading').modal('toggle');
				console.log('filexD - ', errorThrown);
				console.log('filexD - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
        });
    }

    this.setBitacora = function(patient) {
        var dataPost = {
            usrId: patient,
            hf: $("#histFam").val(),
            df: $("#dinFam").val(),
            mc: $("#mc").val(),
            hpa: $("#hpa").val(),
            am: $("#am").val(),
            psi: $("#psi").val(),
            trauma: $("#trauma").val(),
            ps: $("#ps").val()
        };

        var ajaxB = $.ajax({
            contentType: "application/json; charset=utf-8",
			type: "POST",
            url: "../include/4a3cb661b72a9b4baaede9c3098fe9e1.php",
            data: JSON.stringify(dataPost),
			dataType: 'JSON',
			beforeSend: function() {
				$('#loading').modal();
			},
			success: function (response) {
				$('#loading').modal('toggle');
				if (response.errno) {
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                    console.log('filexD - ',response.message)
                } else {
                    $("#successMod").modal();
                }
			},
			error: function (XMLHttpRequest, textStatus, errorThrown){
				$('#loading').modal('toggle');
				console.log('filexD - ', errorThrown);
				console.log('filexD - ', XMLHttpRequest);
				return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
			}
        });
    }

    this.loadFilexD = function() {
        try {
            $(".editar").click(function() {
                var pat = $(".editar").data("pid");
                
                objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("filex","");

				$("#info").load("staff/cHomeA.html", function() {});

				$("#content1").load("staff/filexD.html", function(){
                    that.getBitacora(pat);

                    $("#saveBit").click(function() {
                        that.setBitacora(pat);
                    })
				});
			});
        } catch (x) {
            console.log("filexD: filexD -", x.toString());
        }
    }
}