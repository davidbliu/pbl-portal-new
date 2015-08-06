$.ajax({
      url: requestPath,
      type: requestType,
      data: requestData,
      success:function(data){
        successFunction(data);
      },
      error:function (xhr, textStatus, thrownError){
        errorFunction();
      }
  });

