// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//


$('.photoContainer').each(function (index) {
    var min = 1;
    var max = 4;
    var random = Math.floor(Math.random() * (max - min + 1)) + min;
    $(this).addClass('random' + random);
});

$("#downloadButton").hover(

    function () {
        $("#downloadButton").animate({"background-size": "100%"}, "fast");
    },

    function () {
        $("#downloadButton").animate({"background-size": "90%"}, "fast");
    }
);

