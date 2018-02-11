function newWarnings() {
    var that = this;

    this.reviewWarnings = function (){
        setInterval(function(){ 
            console.log("checa warnings"); 
        }, 30000);
    };

    this.reviewWarningsNow = function () {
        console.log("checa inmediatamente");
    };

    this.getAllwarnings = function () {};
}