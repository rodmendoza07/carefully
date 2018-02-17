function newWarnings() {
    var that = this;

    this.reviewWarnings = function (){
        setInterval(function(){ 
            console.log("checa warnings");
        }, 30000);
    };

    this.reviewWarningsNow = function () {
        that.getAllwarnings();
    };

    this.getAllwarnings = function () {
        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "../include/5aa1aad2f0ae993b2c81e73f2bb6d1d7.php",
            dataType: 'JSON',
            beforeSend: function() {
                $('#loading').modal();
            },
            success: function (response) {
                $('#loading').modal('toggle');
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('newWarnings - ',response.message)
                } else {
                    console.log(response.data);
                    var totalWarnings = response.data.length;
                    var therapist = '';
                    $("#warningsBody").empty();
                    for(var i = 0; i < response.data.length; i++){
                        therapist = response.data[i].dpName;
                        var divD = "<tr><td data-cId='" + response.data[i].cId + "' class='text-center' style='color:#000'>"
                        + moment(response.data[i].dStart).format("DD/MM/YY HH:mm") + " - " + moment(response.data[i].dEnd).format("HH:mm") + "</td><td class='text-center'>"
                        + "<span class='" + response.data[i].dBadge +"'>"+ response.data[i].dStatus +"</span></td><td class='text-center'>"
                        + "<button class='btn btn-primary btn-pill cAcept' data-id='acept_" + response.data[i].cId + "'>Aceptar</button>&nbsp;&nbsp;"
                        + "<button class='btn btn-danger btn-pill cCancel' data-id='cancel_" + response.data[i].cId + "'>Cancel</button></td></tr>"
                        $("#warningsBody").append(divD);
                    }
                    var detailWarning = "";
                  
                    $(".totalWarnings").empty();
                    if (totalWarnings > 0) {
                        $("#totalWarningsBell").append(totalWarnings);
                    }
                    $("#totalWarningsHome").append(totalWarnings);
                    $("#therapistName").empty();
                    $("#therapistName").append(therapist);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                console.log('newWarnings - ', errorThrown);
                console.log('newWarnings - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });
    };

    $("document").ready(function(){
        $("#newWarnings").click(function() {
            $("#mnewWarnings").modal();
            $(".cAcept").click(function(e) {
                var idConfEvent = e.target.dataset.id;
                
            });
            $(".cCancel").click(function(e) {
                console.log(e);
                var idCancelEvent = e.target.dataset.id;
            });
        });

    });
}