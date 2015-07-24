$.ajax({
      url: '/pull_notifications',
      type: 'GET',
      success:function(data){
        $('#notifications-container').html(data);
      },
      error:function (xhr, textStatus, thrownError){
        $('#notifications-container').html('Error Pulling Notifications');
      }
  	});