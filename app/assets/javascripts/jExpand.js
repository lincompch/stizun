(function($){
    $.fn.jExpand = function(){
        var element = this;
        $(element).find("tr.odd").addClass("no-form");
        $(element).find("tr.even").addClass("no-form");

        $(element).find("tr.odd").next("tr").addClass("odd")
        $(element).find("tr.even").next("tr").addClass("even")

        $(element).find("tr.form").hide();

        $(element).find("tr.no-form").click(function() {
            $(this).next("tr").toggle();
        });

    }
})(jQuery);

