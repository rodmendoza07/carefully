function therapistAdd() {
    var that = this;

    var objLanguage = new IdiomaDataTables();
    var objActiveMenu = new activeMenu();

    this.service1 = "";
    this.service2 = "";
    this.service3 = "";
    this.service4 = "";

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
                        $("#service1").change(function() {
                            if (this.checked) {
                                that.service1 = $("#service1").val() + ",";
                            } else {
                                that.service1 = "";
                            }
                        });
                        $("#service2").change(function() {
                            if (this.checked) {
                                that.service2 = $("#service2").val() + ",";
                            } else {
                                that.service2 = "";
                            }
                        });
                        $("#service3").change(function() {
                            if (this.checked) {
                                that.service3 = $("#service3").val() + ",";
                            } else {
                                that.service3 = "";
                            }
                        });
                        $("#service4").change(function() {
                            if (this.checked) {
                                that.service4 = $("#service4").val() + ",";
                            } else {
                                that.service4 = "";
                            }
                        });
                        $("#saveThera").click(function(){
                            if ($("#registerTherapist").valid()) {
                                var servicios = "";
                                servicios = that.service1 + that.service2 + that.service3 + that.service4;
                                if (servicios == "") {
                                    return toastr.warning("Asigna por lo menos un servicio.", "¡Atención!", 5000);
                                }
                                servicios = servicios.split(",");
                                servicios.pop();
                                servicios = servicios.join();
                                var dataPost = {
                                    name: $("#tname").val(),
                                    fname: $("#tfirstname").val(),
                                    lname: $("#tlastname").val(),
                                    email: $("#temail").val(),
                                    service: servicios
                                }
                                console.log(dataPost);
                                var ajaxW = $.ajax({
                                    contentType: "application/json; charset=utf-8",
                                    type: "POST",
                                    url: "include/17dc7aabb6d6484d818fea7460381f6c.php",
                                    data: JSON.stringify(dataPost),
                                    dataType: 'JSON',
                                    beforeSend: function() {
                                    },
                                    success: function (response) {
                                        if (response.errno) {
                                            toastr.error(response.message, "¡Upps!", 5000);
                                            console.log('newWarnings - ',response.message)
                                        } else {
                                            console.log(response);
                                        }
                                    },
                                    error: function (XMLHttpRequest, textStatus, errorThrown){
                                        console.log('therapistAdd - ', errorThrown);
                                        console.log('therapistAdd - ', XMLHttpRequest);
                                        return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                                    }
                                });
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