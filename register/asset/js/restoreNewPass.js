$(document).ready(function() {
    var that = this;
    try {
        $("#restoreNewPass").validate({
            rules: {
                newPasswd: {
                    required: true,
                },
                CnewPasswd: {
                    required: true,
                    equalTo: "#newPasswd"
                }
            },
            messages: {
                newPasswd: {
                    required: "<br><span style='color: red;'>*</span>"
                },
                CnewPasswd: {
                    required: "<br><span style='color: red;'>*</span>",
                    equalTo:"<br><br><span style='color: red;'>Las contraseñas no coinciden</span>"
                }
            }
        });
    
        $("#saveNewPass").click(function() {
            if ($("#restoreNewPass").valid) {
                var newContra = {
                    newPwd: $("#newPasswd").val().trim()
                }
                
                var ajaxF = $.ajax({
                    contentType: "application/json; charset=utf-8",
                    type: "POST",
                    url: "include/restorePassSend.php",
                    dataType: 'JSON',
                    data: JSON.stringify(newContra),
                    beforeSend: function() {
                        $('#loading').modal();
                    },
                    success: function (response) {
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown){
                        $('#loading').modal('toggle');
                        toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                        console.log('RestoreNewPass - ', errorThrown);
                        console.log('RestoreNewPass - ', XMLHttpRequest);
                    }
                });
            }
        });
    } catch (x) {
        toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
        console.log("RestorePass - ", x);
    }
});