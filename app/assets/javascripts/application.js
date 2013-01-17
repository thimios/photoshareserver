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
//= require jquery
//= require jquery_ujs
//= require h5bp



    <!-- Google Analytics: change UA-XXXXX-X to be your site's ID.
    -->

    var _gaq = [
    ['_setAccount', 'UA-XXXXX-X'],
    ['_trackPageview']
    ];
    (function (d, t) {
        var g = d.createElement(t),
        s = d.getElementsByTagName(t)[0];
        g.src = ('https:' == location.protocol ? '//ssl' : '//www') + '.google-analytics.com/ga.js';
        s.parentNode.insertBefore(g, s)
        }(document, 'script'));



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

