$.ajax({
      url: '/calendar_pull',
      type: 'GET',
      success:function(data){
        $('#events-container').html(data);
      },
      error:function (xhr, textStatus, thrownError){
        $('#events-container').html('Error Pulling Events');
      }
  	});