function pullModalContentActions(){
  $('.card-modal-link').unbind('click').click(function(){
  		//make request to pull card
  		$('#modal-card-container').html("<img src = 'http://wpc.077d.edgecastcdn.net/00077D/fender/images/2013/template/drop-nav-loader.gif' height=100></img>");
  		id = $(this).attr('id');
  		$.ajax({
	      url: '/tasks/card/'+id,
	      type: 'GET',
	      success:function(data){
	        $('#modal-card-container').html(data);
	      },
	      error:function (xhr, textStatus, thrownError){
	        $('#modal-card-container').html('<h3>Error Pulling Card Data</h3>');
	      }
	  });
  });
}
pullModalContentActions();