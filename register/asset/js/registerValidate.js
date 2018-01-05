$(document).ready(function() {

    var that = this;

    function getUrlVars() {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
        });
        return vars;
    }

    var codeAccount = getUrlVars()["code"];

    this.invalidR = '<div class="row">'
                        + '<div class="col-md-6 col-md-offset-3">'
                        + '<h1 class="tittle text-center" style="color:red;">'
                            + 'Registro inválido&nbsp;&nbsp;<i class="fa fa-pencil-square-o" aria-hidden="true"></i>'
                        + '</h1>'
                        + '</div>'
                    + '</div>'
                    + '<div class="row" style="padding-top:25px; padding-bottom:50px;">'
                        + '<div class="col-md-4 col-md-offset-4">'
                            + '<button class="btn btn-primary btn-block" id="activateAccount">'
                                + 'Regresar al registro'
                            + '</button>'
                        + '</div>'
                    + '</div>';

    this.validR = '<div class="row">'
                    + '<div class="col-md-6 col-md-offset-3">'
                    + '<h1 class="tittle text-center">'
                        + '¡Cuenta Activada!&nbsp;&nbsp;<i class="fa fa-check" aria-hidden="true"></i>'
                    + '</h1>'
                    + '</div>'
                + '</div>'
                + '<div class="row" style="padding-top:25px; padding-bottom:50px;">'
                    + '<div class="col-md-4 col-md-offset-4">'
                        + '<button class="btn btn-primary btn-block" id="activateAccount">'
                            + 'Iniciar sesión'
                        + '</button>'
                    + '</div>'
                + '</div>';

    if (codeAccount != undefined) {
        if (codeAccount.trim() != '') {

            dataPost = {
                code: codeAccount
            };

            var ajaxF = $.ajax({
                contentType: "application/json; charset=utf-8",
                type: "GET",
                url: "include/validateAccount.php",
                dataType: 'JSON',
                data: dataPost,
                beforeSend: function() {
                    $('#loading').modal();
                },
                success: function (response) {
                    $('#loading').modal('toggle');
                    if (response.errno) {
                        $("#panelbody").empty();
                        $("#panelbody").append(that.invalidR);
                        if (response.message == 'Tu cuenta ya ha sido activada') {
                            toastr.error(response.message, "¡Upps!", 5000 );
                            $("#activateAccount").click(function() {
                                window.location = 'login.html';
                            });
                        } else {
                            toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Upps!", 5000);
                            console.log('Register - ',response.message);
                            $("#activateAccount").click(function() {
                                window.location = 'register.html';
                            });
                        }

                    } else {
                        $("#panelbody").empty();
                        $("#panelbody").append(that.validR);
                        $("#activateAccount").click(function() {
                            window.location = 'login.html';
                        });
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown){
                    $('#loading').modal('toggle');
                    toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                    console.log('Register - ', errorThrown);
                    console.log('Register - ', XMLHttpRequest);
                }
            });

            
        } else {
            $("#panelbody").empty();
            $("#panelbody").append(that.invalidR);
            $("#activateAccount").click(function() {
                window.location = 'register.html';
            });           
        }
    } else {
        $("#panelbody").empty();
        $("#panelbody").append(that.invalidR);
        $("#activateAccount").click(function() {
            window.location = 'register.html';
        });
    }
});