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
                var nombres = $("#names").val().trim();
                var ap = $("#lastnames").val().trim();
                var email = $("#userEmail").val().trim();
                if (pwd != cpwd) {
                    return toastr.error("La contraseñas no coinciden","¡Ups! Error");
                }
                
                
                var dataPost = {
                    names: nombres,
                    lastnames: ap,
                    userEmail: email,
                    pwd: pwd
                };
                
                console.log(dataPost);
                
                var ajaxF = $.ajax({
                    contentType: "application/json; charset=utf-8",
                    type: "POST",
                    url: "https://salty-harbor-47251.herokuapp.com/newUsers",
                    data: dataPost,
                    dataType: 'JSON',
                        data: JSON.stringify(dataPost),
                        beforeSend: function() {
                            $('#loading').modal();
                        },
                        success: function (response) {
                            $('#loading').modal('toggle');
                            $("#names").val("");
                            $("#lastnames").val("");
                            $("#userEmail").val("");
                            $("#pwd").val("");
                            $("#cpwd").val("");
                            $('#confirmEmail').modal();
                            console.log(response);
                        },
                    error: function (XMLHttpRequest, textStatus, errorThrown){
                        toastr.error(errorThrown, "¡Atención!");
                    }
                });
                console.log(ajaxF);
            }
        });

        $("#activateSes").click(function(){
            $("#confirmEmail").modal("toggle");
        });

    } catch (x) {
        console.log(x);
    }
});