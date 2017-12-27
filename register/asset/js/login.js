$(document).ready(function(){
    var that = this;

    try {
        jQuery.validator.addMethod("lettersonly", 
            function (value, element) {
                return this.optional(element) || /^[a-z\s]+$/i.test(value);
            },
            "Solo se permiten letras y espacios."
        );

        $("#register").validate({
            rules: {
                names: {
                    required: true,
                    lettersonly: true
                },
                lastnames: {
                    required: true,
                    lettersonly: true
                },
                pwd: {
                    required: true,
                    minlength: 6,
                    maxlength: 10
                },
                cpwd: {
                    required: true,
                    equalTo: "#pwd"
                },
                userEmail: {
                    required: true,
                    email:true
                },
                disclaimer: {
                    required: true
                }
            },
            messages: {
                names: {
                    required: "<br><span style='color: red;'>*</span>",
                    lettersonly: "<br><br><span style='color: red;'>Solo se permiten letras y espacios.</span>"
                },
                lastnames:{
                    required: "<br><span style='color: red;'>*</span>",
                    lettersonly: "<br><br><span style='color: red;'>Solo se permiten letras y espacios.</span>"
                },
                pwd: "<br><span style='color: red;'>*</span>",
                cpwd: {
                    required: "<br><span style='color: red;'>*</span>",
                    equalTo:"<br><br><span style='color: red;'>Las contraseñas no coinciden</span>"
                },
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
                    url: "http://localhost:3000/newUsers",
                    //url: "https://salty-harbor-47251.herokuapp.com/newUsers",
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
                        $('#loading').modal('toggle');
                        $("#names").val("");
                        $("#lastnames").val("");
                        $("#userEmail").val("");
                        $("#pwd").val("");
                        $("#cpwd").val("");
                        toastr.error("Error: " + errorThrown, "¡Atención!");
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