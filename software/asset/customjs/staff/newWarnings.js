function newWarnings() {
    var that = this;

    this.reviewWarnings = function (){
        setInterval(function(){ 
            console.log("checa warnings");
            that.getAllWarningNumbers();
        }, 120000);
    };

    this.reviewWarningsNow = function () {
        that.getAllWarningNumbers();
    };

    this.getAllWarningNumbers = function() {
        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "../include/c0c6123e62150bcfeac54bc06a055bc8.php",
            dataType: 'JSON',
            beforeSend: function() {},
            success: function (response) {
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('newWarnings - ',response.message)
                } else {
                    var totalWarnings = response.data.length;
                    
                    if (totalWarnings == 0) {
                        $("#totalWarningsBell").empty();
                    } else {
                      
                        $(".totalWarnings").empty();
                        if (totalWarnings > 0) {
                            $("#totalWarningsBell").append(totalWarnings);
                        }
                    }
                    $("#totalWarningsHome").empty();
                    $("#totalWarningsHome").append(totalWarnings);
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                console.log('newWarnings - ', errorThrown);
                console.log('newWarnings - ', XMLHttpRequest);
                return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
            }
        });
    };

    this.getAllwarnings = function () {
        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "../include/c0c6123e62150bcfeac54bc06a055bc8.php",
            dataType: 'JSON',
            beforeSend: function() {},
            success: function (response) {
                if (response.errno) {
                    toastr.error(response.message, "¡Upps!", 5000);
                    console.log('newWarnings - ',response.message)
                } else {
                    var totalWarnings = response.data.length;
                    
                    if (totalWarnings == 0) {
                        $("#theadWarnings").empty();
                        $("#warningsBody").empty();
                        $("#bodyWarnings").empty();
                        $("#bodyWarnings").append(
                            "<h2>No hay avisos nuevos</h2>"
                        );
                    } else {
                        var theader = "<tr>"
                                        + "<th class='text-center' style='background: #8CC63F; color:white;'>Fecha(s)</th>"
                                        + "<th class='text-center' style='background: #8CC63F; color:white;'>Acciones</th>"
                                        + "<th class='text-center' style='background: #8CC63F; color:white;'>Estatus</th>"
                                    + "</tr>";
                        $("#theadWarnings").empty();
                        $("#theadWarnings").append(theader);
                        $("#bodyWarnings").empty();
                        $("#warningsBody").empty();
                        for(var i = 0; i < response.data.length; i++){
                            var divD;
                            if (response.data[i].dStatus == 'Cancelada') {
                                divD = "<tr><td data-cId='" + response.data[i].cId + "' class='text-center' style='color:#000'>"
                                + moment(response.data[i].dStart).format("DD/MM/YY HH:mm") + " - " + moment(response.data[i].dEnd).format("HH:mm") + "</td><td class='text-center'>"
                                + "<span class='" + response.data[i].dBadge +" care-warning'>"+ response.data[i].dStatus
                                + "</span>" +  response.data[i].dpName + "</td><td class='text-center'>"
                                + "<button class='btn btn-primary btn-pill-small cAcept' data-id='acept_" + response.data[i].cId + "' data-ps='"
                                + response.data[i].dStatus + "'>Aceptar</button></td></tr>"
                            } else {
                                divD = "<tr><td data-cId='" + response.data[i].cId + "' class='text-center' style='color:#000'>"
                                + moment(response.data[i].dStart).format("DD/MM/YY HH:mm") + " - " + moment(response.data[i].dEnd).format("HH:mm") + "</td><td class='text-center'>"
                                + "<span class='" + response.data[i].dBadge +" care-warning'>"+ response.data[i].dStatus
                                + "</span>" +  response.data[i].dpName + "</td><td class='text-center'>"
                                + "<button class='btn btn-primary btn-pill-small cAcept' data-id='acept_" + response.data[i].cId + "' data-ps='"
                                + response.data[i].dStatus + "'>Aceptar</button>&nbsp;&nbsp;"
                                + "<button class='btn btn-danger btn-pill-small cCancel' data-id='cancel_" + response.data[i].cId + "' data-ps='"
                                + response.data[i].dStatus + "'>Cancel</button></td></tr>"
                            }
                            $("#warningsBody").append(divD);
                        }
                        var detailWarning = "";

                        $(".cAcept").click(function(e) {
                                var idConfEvent = e.target.dataset.id;
                                var prevStat = e.target.dataset.ps;
                                var dataPost = { cId : idConfEvent, prevS: prevStat};
                                var ajaxW = $.ajax({
                                    contentType: "application/json; charset=utf-8",
                                    type: "POST",
                                    url: "../include/2d0e9de048e9f2b686ef346c4b716d39.php",
                                    data: JSON.stringify(dataPost),
                                    dataType: 'JSON',
                                    beforeSend: function() {},
                                    success: function (response) {
                                        if (response.errno) {
                                            toastr.error(response.message, "¡Upps!", 5000);
                                            console.log('newWarnings - ',response.message)
                                        } else {
                                            that.getAllwarnings();
                                            that.getAllWarningNumbers();
                                        }
                                    },
                                    error: function (XMLHttpRequest, textStatus, errorThrown){
                                        $('#mnewWarnings').modal('toggle');
                                        console.log('newWarnings - ', errorThrown);
                                        console.log('newWarnings - ', XMLHttpRequest);
                                        return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                                    }
                                });
                        });

                        $(".cCancel").click(function(e) {
                            console.log(e);
                            var idCancelEvent = e.target.dataset.id;
                            var prevStat = e.target.dataset.ps;
                            var dataPost = { cId : idCancelEvent, prevS: prevStat};
                            console.log(dataPost);
                            var ajaxW = $.ajax({
                                contentType: "application/json; charset=utf-8",
                                type: "POST",
                                url: "../include/2d0e9de048e9f2b686ef346c4b716d39.php",
                                data: JSON.stringify(dataPost),
                                dataType: 'JSON',
                                beforeSend: function() {},
                                success: function (response) {
                                    if (response.errno) {
                                        toastr.error(response.message, "¡Upps!", 5000);
                                        console.log('newWarnings - ',response.message)
                                    } else {
                                        that.getAllwarnings();
                                        that.getAllWarningNumbers();
                                    }
                                },
                                error: function (XMLHttpRequest, textStatus, errorThrown){
                                    $('#mnewWarnings').modal('toggle');
                                    console.log('newWarnings - ', errorThrown);
                                    console.log('newWarnings - ', XMLHttpRequest);
                                    return toastr.error("Algo ha ido mal, por favor intentalo más tarde.", "¡Atención!", 5000);
                                }
                            });
                        });
                    }
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

            that.getAllwarnings();

        });

    });
}