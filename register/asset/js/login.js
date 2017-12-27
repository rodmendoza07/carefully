$(document).ready(function(){
    var that = this;

    try {
        $("#formLogin").validate({
            rules: {
                userName: "required",
                passwd: "required"
            },
            messages: {
                userName: '<br><span style="color:red;">*</span>',
                passwd: '<br><span style="color:red;">*</span>'
            }
        });

        $("#startSess").click(function() {
            if ($("#formLogin").valid()) {
                console.log("submit");
                var dataPost = {
                    userName: $("#userName").val().trim(),
                    passwd: $("#passwd").val().trim()
                };
                var ajaxF = $.ajax({
                    contentType: "application/json; charset=utf-8",
                    type: "POST",
                    url: "http://localhost:3000/login",
                    //url: "https://salty-harbor-47251.herokuapp.com/newUsers",
                    //data: dataPost,
                    dataType: 'JSON',
                    data: JSON.stringify(dataPost),
                    beforeSend: function() {
                        $('#loading').modal();
                    },
                    success: function (response) {
                        //$('#loading').modal('toggle');
                        console.log(response);
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown){
                        $('#loading').modal('toggle');
                        toastr.error("Error: " + errorThrown, "¡Atención!");
                    }
                });
            }
        });
        // $("#continueRegister").click(function(){
        //     if ($("#register").valid()) {
        //         var pwd = $("#pwd").val().trim();
        //         var cpwd = $("#cpwd").val().trim();
        //         var nombres = $("#names").val().trim();
        //         var ap = $("#lastnames").val().trim();
        //         var email = $("#userEmail").val().trim();
        //         if (pwd != cpwd) {
        //             return toastr.error("La contraseñas no coinciden","¡Ups! Error");
        //         }
                
                
        //         var dataPost = {
        //             names: nombres,
        //             lastnames: ap,
        //             userEmail: email,
        //             pwd: pwd
        //         };
                
        //         console.log(dataPost);
                
        //         var ajaxF = $.ajax({
        //             contentType: "application/json; charset=utf-8",
        //             type: "POST",
        //             url: "http://localhost:3000/newUsers",
        //             //url: "https://salty-harbor-47251.herokuapp.com/newUsers",
        //             data: dataPost,
        //             dataType: 'JSON',
        //                 data: JSON.stringify(dataPost),
        //                 beforeSend: function() {
        //                     $('#loading').modal();
        //                 },
        //                 success: function (response) {
        //                     $('#loading').modal('toggle');
        //                     $("#names").val("");
        //                     $("#lastnames").val("");
        //                     $("#userEmail").val("");
        //                     $("#pwd").val("");
        //                     $("#cpwd").val("");
        //                     $('#confirmEmail').modal();
        //                     console.log(response);
        //                 },
        //             error: function (XMLHttpRequest, textStatus, errorThrown){
        //                 $('#loading').modal('toggle');
        //                 $("#names").val("");
        //                 $("#lastnames").val("");
        //                 $("#userEmail").val("");
        //                 $("#pwd").val("");
        //                 $("#cpwd").val("");
        //                 toastr.error("Error: " + errorThrown, "¡Atención!");
        //             }
        //         });
        //         console.log(ajaxF);
        //     }
        // });

        $("#activateSes").click(function(){
            $("#confirmEmail").modal("toggle");
        });

    } catch (x) {
        console.log(x);
    }
});