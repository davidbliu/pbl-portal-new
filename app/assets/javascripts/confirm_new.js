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
function approveAll(){
    $('#approve-btn').click(function(){
        var r = confirm('would you like to save changes?');
        if(!r){
            return;
        }
        var member_data = new Array();
        $('.member-row').each(function(){
            var new_member = {};

            var committee = $(this).children('.committee')[0];
            var committeeDropdown = $(committee).children()[0];
            var committeeSelectedID = $(committeeDropdown).find('option:selected').attr('id');

            var position = $(this).children('.position')[0];
            var positionDropdown = $(position).children()[0];
            var positionSelectedID = $(positionDropdown).find('option:selected').attr('id');
            var positionSelectedText = $(positionDropdown).find('option:selected').text();

            new_member.id = $(this).attr('id');
            new_member.committee_id = committeeSelectedID;
            new_member.position_id = positionSelectedID;
            new_member.position_name = positionSelectedText;
            member_data.push(new_member);
        });
        console.log(member_data);
        $.ajax({
          url:'/members/process_new',
          type: "GET",
          data: {"member_data": member_data}
        }).done(function(data){
            // location.reload();
            alert('success');
        }).fail(function(data){
            alert('failed');
        });

    });
}
$(document).ready(function(){

    approveAll();
});

