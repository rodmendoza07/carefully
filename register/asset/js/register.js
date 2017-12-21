$(document).ready(function(){
    var that = this;

    try {
          
        $("#register").validate({
            rules: {
                names: "required",
                lastnames: "required",
                pwd: "required",
                cpwd: "required",
                userEmail: {
                    required: true,
                    email:true
                },
                disclaimer: {
                    required: true
                }
            },
            messages: {
                names: "<br><span style='color: red;'>*</span>",
                lastnames: "<br><span style='color: red;'>*</span>",
                pwd: "<br><span style='color: red;'>*</span>",
                cpwd: "<br><span style='color: red;'>*</span>",
                userEmail: {
                    required: "<br><span style='color: red;'>*</span>",
                    email: "<br><br><span style='color: red;'>Ingresa un correo válido </span>"
                },
                disclaimer: "<br><span style='color: red; font-weight: bold;'>*</span>"
            }
        });

        $("#continueRegister").click(function(){
            if ($("#register").valid()) {
                var pwd = $("#pwd").val().trim();
                var cpwd = $("#cpwd").val().trim();
    
                if (pwd != cpwd) {
                    return toastr.error("La contraseñas no coinciden","¡Ups! Error");
                }
                console.log("pasa");
            }
        });
        
    } catch (x) {
        console.log(x);
    }
});