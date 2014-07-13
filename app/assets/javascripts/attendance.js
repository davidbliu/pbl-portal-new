function scrollActions(){
  //scroll sidebar with the page
  // $fixed_head = $("#original-fixed-head").clone()
  $("#original-fixed-head").clone().appendTo($('#clone-thead'));
     var $sidebar   = $('#clone-thead'),
        $window    = $(window),
        offset     = $sidebar.offset(),
        topPadding = 0;

    $window.scroll(function() {
        if ($window.scrollTop() > offset.top) {
            $sidebar.animate({
                marginTop: $window.scrollTop()+topPadding
            });
        } else {
            $sidebar.stop().animate({
                marginTop: 0
            });
        }
    });
}

$(document).ready(function(){


	// scrollActions();
	console.log('started scrollactions');
	$('.member-row').click(function(){
		 var state = $(this).hasClass('highlighted');
    	$('.highlighted').removeClass('highlighted');
    	if ( ! state) { $(this).addClass('highlighted'); }
	});
	console.log('working...');
});

