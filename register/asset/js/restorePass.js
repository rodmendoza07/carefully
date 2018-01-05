$(document).ready(function() {
    var that = this;

    try {
        $("#restorePass").validate({
            rules: {
                userEmail: {
                    required: true,
                    email:true
                },
                CuserEmail: {
                    required: true,
                    email:true,
                    equalTo: "#userEmail"
                }
            },
            messages: {
                userEmail: {
                    required: "<br><span style='color: red;'>*</span>",
                    email: "<br><br><span style='color: red;'>Ingresa un correo válido </span>"
                },
                CuserEmail: {
                    required: "<br><span style='color: red;'>*</span>",
                    email: "<br><br><span style='color: red;'>Ingresa un correo válido </span>",
                    equalTo:"<br><br><span style='color: red;'>Los correos no coinciden</span>"
                }
            }
        });

        $("#continueRestorePass").click(function() {
           if ($("#restorePass").valid()) {
                var correo = $("#userEmail").val().trim();

                var dataPost = {
                    userEmail: correo
                };
                var ajaxF = $.ajax({
                    contentType: "application/json; charset=utf-8",
                    type: "POST",
                    url: "include/restorePassSend.php",
                    dataType: 'JSON',
                    data: JSON.stringify(dataPost),
                    beforeSend: function() {
                        $('#loading').modal();
                    },
                    success: function (response) {
                        $('#loading').modal('toggle');
                        if (response.errno) {
                            toastr.error(response.message + "<br>Por favor comunicate con soporte técnico.", "¡Upps!", 5000);
                            console.log('RestorePass - ',response.message)
                        } else {
                            var dataMail = {
                                email: correo,
                                hash: response.data
                            };
                            var ajaxM = $.ajax({
                                contentType: "application/json; charset=utf-8",
                                type: "POST",
                                url: "include/mailRestorePass.php",
                                dataType: 'JSON',
                                data: JSON.stringify(dataMail),
                                beforeSend: function() {
                                    $('#loading').modal();
                                },
                                success: function (res) {
                                    $("#confirmEmail").modal();
                                    $("#activateSes").click(function() {
                                        window.location = 'login.html';
                                    });
                                },
                                error: function (XMLHttpRequest, textStatus, errorThrown){
                                    $('#loading').modal('toggle');
                                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                                    console.log('RestorePass - ', errorThrown);
                                    console.log('RestorePass - ', XMLHttpRequest);
                                }
                            });
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown){
                        $('#loading').modal('toggle');
                        toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                        console.log('RestorePass - ', errorThrown);
                        console.log('RestorePass - ', XMLHttpRequest);
                    }
                });
           }
        });
    } catch (x) {
        toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
        console.log("RestorePass - ", x);
    }
});