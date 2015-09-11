function showSpinner(){
	$('#loading-gif').show();
}
function hideSpinner(){
	$('#loading-gif').hide();
}
function changeModal(email, name){
	showSpinner();
	$.ajax({
      url: '/members/profile_card',
      type: 'get',
      data: {'email': email},
      success:function(data){
      	hideSpinner();
        $('#modal-title').text(name);
        $('#modal-body').html(data);
      },
      error:function (xhr, textStatus, thrownError){
      	hideSpinner();
        // alert('failed');
      }
  });
}
$('.member-link').click(function(){
	email = $(this).attr('data-email');
	name = $(this).attr('data-name');
	console.log(email);
	changeModal(email, name);

});