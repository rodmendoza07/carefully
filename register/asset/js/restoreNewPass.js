$(document).ready(function() {
    var that = this;

    function getUrlVars() {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
        });
        return vars;
    }

    try {
        $("#restoreNewPass").validate({
            rules: {
                newPasswd: {
                    required: true,
                    minlength: 6
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
            if ($("#restoreNewPass").valid()) {
                var codeAccount = getUrlVars()["code"];

                var newContra = {
                    newPwd: $("#newPasswd").val().trim(),
                    hashVal: codeAccount
                }
                
                var ajaxF = $.ajax({
                    contentType: "application/json; charset=utf-8",
                    type: "POST",
                    url: "include/restoreNewPass.php",
                    dataType: 'JSON',
                    data: JSON.stringify(newContra),
                    beforeSend: function() {
                        $('#loading').modal();
                    },
                    success: function (response) {
                        $('#loading').modal('toggle');
                        if (response.errno) {
                            toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                            console.log('Register - ',response.message)
                        } else {
                            $("#newPasswd").val('');
                            $("#CnewPasswd").val('');
                            $("#continueLog").modal();
                            $("#continueLogin").click(function() {
                                window.location = 'login.html';
                            });                            
                        }
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