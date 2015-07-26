function pullModalContentActions(){
  $('.metrics-modal-link').unbind('click').click(function(){
  		//make request to pull card
  		key = $(this).attr('id');
  		console.log(key);
  		$('#metrics-modal-container').html("<img src = 'http://wpc.077d.edgecastcdn.net/00077D/fender/images/2013/template/drop-nav-loader.gif' height=100></img>");
  		id = $(this).attr('id');
  		$.ajax({
	      url: '/go/'+key+'/metrics',
	      type: 'GET',
	      success:function(data){
	        $('#metrics-modal-container').html(data);
	      },
	      error:function (xhr, textStatus, thrownError){
	        $('#modal-modal-container').html('<h3>Error Pulling Link Metrics</h3>');
	      }
	  });
  });
}
pullModalContentActions();