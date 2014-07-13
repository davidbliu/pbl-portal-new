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
function checkActions(){
    $('.attendance-checkbox').click(function(){
        if ($(this).text() == "X"){
            $(this).text("");
        }
        else{
            $(this).text("X");
        }
        if($(this).hasClass('changed')){
            $(this).removeClass('changed');
        }
        else{
            $(this).addClass("changed");
        }
    });
}
function saveActions(){
    $('#save-btn').click(function(){
        if(!admin){
            alert("you cannot make changes to attendance")
            return;
        }
        var r = confirm('would you like to save changes to attendance?')
        if(!r){
            return;
        }
        attendance_data = [];
        remove_data = [];
        $('.changed').each(function(){
            if($(this).text() == "X"){
                parts = $(this).attr('id').split(',');
                attendance_data.push({'event_id': parts[0], 'member_id': parts[1]})
            }
            else{
                // attendance was removed
                parts = $(this).attr('id').split(',');
                remove_data.push({'event_id': parts[0], 'member_id': parts[1]})
            }
        });
        console.log(attendance_data)
        $.ajax({
          url:'/points/update_attendance',
          type: "POST",
          data: {"attendance_data": attendance_data, "remove_data": remove_data}
        }).done(function(data){
            location.reload();
        }).fail(function(data){
            alert('failed');
        });

    });
}
$(document).ready(function(){


	// scrollActions();
    checkActions();
    saveActions();
	console.log('started scrollactions');
	$('.locked-left').click(function(){
        $row = $(this).parent();
		 var state = $row.hasClass('highlighted');
    	$('.highlighted').removeClass('highlighted');
    	if ( ! state) { $row.addClass('highlighted'); }
	});
	console.log('working...');
});

