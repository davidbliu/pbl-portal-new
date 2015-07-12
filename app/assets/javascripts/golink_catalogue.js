/** 
* MODAL STUFF
*/
function pullModalContentActions(){
  $('.link-modal').click(function(){
    // id = $(this).attr('id');
    hidden_info = $(this).find('.hidden-edit-info').html();
    //change modal content
    hidden = $(this).find('.hidden-edit-info');
    key = $(hidden).find('#go-key-input').val();
    id = $(hidden).find('#go-id-input').val();
    url = $(hidden).find('#go-url-input').val();
    description = $(hidden).find('#go-description-input').val();
    directory = $(hidden).find('#go-directory-input').val();
    // console.log('id was '+id + ' url was '+url + ' description was '+description + ' directory was ' + directory);

    $('#edit-modal-content').find('#go-id-input').val(id);
    $('#edit-modal-content').find('#go-key-input').val(key);
    $('#edit-modal-content').find('#go-url-input').val(url);
    $('#edit-modal-content').find('#go-description-input').val(description);
    $('#edit-modal-content').find('#directories-dropdown').find($(document.getElementById(directory)).prop({selected: true}));

    // $('#edit-modal-content').html(hidden_info);
    $('#myModalLabel').html($(this).find('.hidden-edit-info').attr('id').split(',')[0]);
  });
}
function colorRowError(row ){
	if ($(row).hasClass('row-editing')){
    	$(row).removeClass('row-editing');
    }
    if ($(row).hasClass('row-error')){
    	$(row).removeClass('row-error');
    }
    if ($(row).hasClass('row-success')){
    	$(row).removeClass('row-success');
    }
    $(row).addClass('row-error');
}
function colorRowSuccess(row){
	if ($(row).hasClass('row-editing')){
    	$(row).removeClass('row-editing');
    }
    if ($(row).hasClass('row-error')){
    	$(row).removeClass('row-error');
    }
    if ($(row).hasClass('row-success')){
    	$(row).removeClass('row-success');
    }
    $(row).addClass('row-success');
}
function colorRowEditing(row){
	if ($(row).hasClass('row-editing')){
    	$(row).removeClass('row-editing');
    }
    if ($(row).hasClass('row-error')){
    	$(row).removeClass('row-error');
    }
    if ($(row).hasClass('row-success')){
    	$(row).removeClass('row-success');
    }
    $(row).addClass('row-editing');
}
function updateLinkActions(){
  $("#save-link-btn").click(function(){
  id = $('#edit-modal-content').find("#go-id-input").val();
  key = $('#edit-modal-content').find("#go-key-input").val();
  url = $('#edit-modal-content').find("#go-url-input").val();
  description = $('#edit-modal-content').find("#go-description-input").val();
  directory = $('#edit-modal-content').find('#directories-dropdown').find(":selected").attr('id');
  console.log($('#edit-modal-content'));
  console.log('url was '+url);
  console.log('description was '+description);
  console.log('directory was '+directory);
  console.log('id was '+id);
  console.log('key was '+key);
  // make the row for this one orange
  row = $('#' + key + '-separator-row');

  //color the row orange because it is being edited
  colorRowEditing(row);
  $.ajax({
      url: '/go/' + id + '/update',
      type: 'POST',
      data: {'url': url ,'description': description, 'directory': directory},
      success:function(data){
      	//description
      	$(row).find('.golink-description-td').text(description);
      	$(row).find('#go-description-input').val(description);
      	//directory
      	$(row).find('#go-directory-input').val(directory);

      	//url
      	$(row).find('#go-url-input').val(url);
        colorRowSuccess(row);
      },
      error:function (xhr, textStatus, thrownError){
        alert('Failed');
        colorRowError(row);
        
        
      }
    });
});
}
function deleteLinkActions(){
   $("#delete-link-btn").click(function(){
  var id = $('#edit-modal-content').find("#go-id-input").val();
  window.location.replace("/go/"+id+"/destroy");
  // window.location = 
}); 
}

function clipboardCopyActions(){
  $('.clipboard-copy').click(function(event){
    event.preventDefault();
    id = $(this).attr('id');
    window.prompt("Copy to clipboard: Ctrl+C, Enter", id);
  }             
);
}

function directoryLinkScrollActions(){
	$('.directory-link').click(function(event){
	    event.preventDefault();
	    id = $(this).attr('href');
	    console.log(id);
	    // $(this).next('div').slideToggle(200);
	    $('html, body').animate({
	        scrollTop: ($(id).offset().top - 100)
	    }, 200);
	  }             
	);
}
function favoriteLinkActions(){
	$('.favorite-link').click(function(event){
		event.preventDefault();
		key = $(this).attr('id').split(',')[0];
		member_email = email;
		
		if($(this).hasClass("mdi-action-favorite-outline")){
			status = 'favorite';
		}
		else{
			status = 'unfavorite';
		}
		console.log(key);
		console.log(member_email);
		console.log(status);
		that = $(this);
		$.ajax({
	      url: '/go/favorite',
	      type: 'GET',
	      data: {'email': member_email ,'key': key, 'status': status},
	      success:function(data){
	        //switch classes for favorite icon
	        // alert('done'); 
	        if($(that).hasClass('mdi-action-favorite-outline')){
	        	$(that).removeClass('mdi-action-favorite-outline');
	        	$(that).addClass('mdi-action-favorite');
	        }
	        else{
	        	$(that).removeClass('mdi-action-favorite');
	        	$(that).addClass('mdi-action-favorite-outline');
	        }
	      },
	      error:function (xhr, textStatus, thrownError){
	        alert('Failed');
	      }
	    });
	});
}

$(document).ready(function(){
	directoryLinkScrollActions();
	  pullModalContentActions();
	  updateLinkActions();
	  deleteLinkActions();
	  
	  clipboardCopyActions();
	  favoriteLinkActions();
});
	