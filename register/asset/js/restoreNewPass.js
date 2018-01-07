$(document).ready(function() {
    var that = this;
    try {
        $("#restorePass").validate({
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
    
        });
    } catch (x) {
        toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
        console.log("RestorePass - ", x);
    }
});