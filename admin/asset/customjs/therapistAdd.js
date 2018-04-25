function therapistAdd() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.loadTherapist = function() {
        try {
            $(".therapistAdd").click(function() {
				objActiveMenu.emptyInfoMenu();
				objActiveMenu.activate("therapist","therapistAdd");
	
				$("#content1").load("view/therapistAdd.html", function(){
                    try {
                        $("#registerTherapist").validate({
                            rules: {
                                tname: {
                                    required: true
                                },
                                tfirstname: {
                                    required: true
                                },
                                tlastname: {
                                    required: true
                                },
                                temail: {
                                    required:true,
                                    email:true
                                }
                            },
                            messages: {
                                tname: {
                                    required: "<br><span style='color: red; font-weight: bold;'>Campo obligatorio *</span>",
                                },
                                tfirstname: {
                                    required: "<br><span style='color: red; font-weight: bold;'>Campo obligatorio *</span>",
                                },
                                tlastname: {
                                    required: "<br><span style='color: red; font-weight: bold;'>Campo obligatorio *</span>",
                                },
                                temail: {
                                    required: "<br><span style='color: red; font-weight: bold;'>Campo obligatorio *</span>",
                                    email: "<br><br><span style='color: red;'>Ingresa un correo válido </span>"
                                }
                            }
                        });
                        $("#saveThera").click(function(){
                            if ($("#registerTherapist").valid()) {
                                console.log("17dc7aabb6d6484d818fea7460381f6c");
                                console.log( $( "input:checked" ).val());
                                var dataPost = {
                                    name: $("#tname").val(),
                                    fname: $("#tfirstname").val(),
                                    lname: $("#tlastname").val(),
                                    email: $("#temail").val(),
                                }
                                console.log(dataPost);
                                // var ajaxW = $.ajax({
                                //     contentType: "application/json; charset=utf-8",
                                //     type: "POST",
                                //     url: "../include/17dc7aabb6d6484d818fea7460381f6c.php",
                                //     data: JSON.stringify(dataPost),
                                //     dataType: 'JSON',
                                //     beforeSend: function() {
                                //     },
                                //     success: function (response) {
                                //         if (response.errno) {
                                //             toastr.error(response.message, "¡Upps!", 5000);
                                //             console.log('newWarnings - ',response.message)
                                //         } else {
                                //             that.getAllwarnings();
                                //             that.getAllWarningNumbers();
                                //         }
                                //     },
                                //     error: function (XMLHttpRequest, textStatus, errorThrown){
                                //         $('#mnewWarnings').modal('toggle');
                                //         console.log('newWarnings - ', errorThrown);
                                //         console.log('newWarnings - ', XMLHttpRequest);
                                //         return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                                //     }
                                // });
                            }
                        });
                    } catch (x) {
                        console.log(x);
                    }
                });
			});
        } catch(x) {
            console.log("therapistAdd: loadTherapist -", x.toString());
        }
    }
}