$(document).ready(function(){
    var that = this;

    try {
        $("#formLogin").validate({
            rules: {
                userName: {
                    required: true,
                    email: true
                },
                passwd: {
                    required: true,
                    minlength: 6
                }
            },
            messages: {
                userName: {
                    required: "<br><span style='color: red; font-weight: bold;'>*</span>",
                    email: "<br><br><span style='color: red;'>Ingresa un correo válido </span>"
                },
                passwd: '<br><span style="color:red; font-weight: bold;">*</span>'
            }
        });

        $("#startSess").click(function() {
            if ($("#formLogin").valid()) {
                console.log("submit");
                var response = "Activa tu cuenta para iniciar sesión"; 
                var dataPost = {
                    userName: $("#userName").val().trim(),
                    passwd: $("#passwd").val().trim()
                };
                
                $("#showErr").append(
                    '<div class="panel panel-danger">'
                        + '<div class="panel-heading">'
                            + '<span style="color: #fff;">'
                                + '<i class="fa fa-exclamation-triangle" aria-hidden="true"></i>&nbsp;&nbsp;'
                                + response
                            + '</span>'
                        + '</div>'
                    + '</div>'
                );
                // var ajaxF = $.ajax({
                //     contentType: "application/json; charset=utf-8",
                //     type: "POST",
                //     url: "http://localhost:3000/login",
                //     //url: "https://salty-harbor-47251.herokuapp.com/newUsers",
                //     //data: dataPost,
                //     dataType: 'JSON',
                //     data: JSON.stringify(dataPost),
                //     beforeSend: function() {
                //         $('#loading').modal();
                //     },
                //     success: function (response) {
                //         //$('#loading').modal('toggle');
                //         console.log(response);
                //     },
                //     error: function (XMLHttpRequest, textStatus, errorThrown){
                //         $('#loading').modal('toggle');
                //         toastr.error("Error: " + errorThrown, "¡Atención!");
                //     }
                // });
            }
        });
        $("#activateSes").click(function(){
            $("#confirmEmail").modal("toggle");
        });

    } catch (x) {
        console.log(x);
    }
});