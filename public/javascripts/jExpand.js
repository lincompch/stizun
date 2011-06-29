(function($){
    $.fn.jExpand = function(){
        var element = this;
        $(element).find("tr.odd").next("tr").addClass("odd")
        $(element).find("tr.even").next("tr").addClass("even")
        
        $(element).find("tr:odd").addClass("no-form");
        $(element).find("tr:not(.no-form)").hide();
        $(element).find("tr:first-child").show();

        $(element).find("tr.no-form").click(function() {
            
            $(this).next("tr").toggle();
        });
        
    }    
})(jQuery); 
