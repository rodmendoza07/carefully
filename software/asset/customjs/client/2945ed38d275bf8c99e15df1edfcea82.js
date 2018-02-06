function f2945ed38d275bf8c99e15df1edfcea82() {
    var that = this;

    this.fff2945ed38d275bf8c99e15df1edfcea82 = function () {
        //var states = false;

        var ajaxF = $.ajax({
            contentType: "application/json; charset=utf-8",
            type: "POST",
            url: "include/3b5944260778d37989c6866f51082ca7.php",
            dataType: 'JSON',
            async: false,
            beforeSend: function() {
                $('#loading').modal();
            },
            success: function (response) {
                //$('#loading').modal('toggle');
                if (response.errno) {
                    return states = false;
                } else {
                    return states = true;
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown){
                return states = false;
            }
        });
        return states;
    }
}