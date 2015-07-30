function filterGolinks(){
	$('.link-row').each(function(){
		$(this).show();
	});
	//unhighlight all tags
	$('.golink-tag').each(function(){
		if($(this).hasClass('selected-tag')){
			$(this).removeClass('selected-tag');
		}
	});
	selected_tags = [];
	$('.tag-cloud-tag').each(function(){
		if($(this).hasClass('selected-tag')){
			selected_tags.push($(this).attr('id').split('-tag')[0]);
		}
	});
	console.log('these tags are selected');
	console.log(selected_tags.uniq);
	if (selected_tags.length > 0){
		$('.link-row').each(function(){
			key = $(this).attr('id').split('-row')[0];
			tags = tag_hash[key];
			for(var j=0;j<selected_tags.length;j++){
				if(tags.indexOf(selected_tags[j]) == -1){
					$(this).hide();
					// break;
				}
			}
		});
	}
	//highlight all tags
	$('.golink-tag').each(function(){
		tag = $(this).text();
		//account for the x link
		// tag = tag.substring(0, tag.length-2);
		if(selected_tags.indexOf(tag) != -1){
			$(this).addClass('selected-tag');
		}
	});
}

function rankLinkActions(){
	$('.rank-input').unbind('keypress').keypress(function(e) {
		if(e.which == 13) {
			rank = $(this).val();
			key = $(this).attr('id').split('-rank-input')[0];
			console.log(rank);
			console.log(key);
			//ajax save this
			$('#spinner-div').show();
			$.ajax({
			      url: '/go/update_rank',
			      type: 'POST',
			      data: {'key': key, 'email':email, 'rank': rank},
			      success:function(data){
			        reinsertLink($('#' + key + '-row'));
			        $('#spinner-div').hide();
			      },
			      error:function (xhr, textStatus, thrownError){
			        console.log('error saving ranking');
			        $('#spinner-div').hide();
			      }
			  });

			
		}
	});
}

function reinsertLink(link_row){
	rank = parseInt($(link_row).find('.rank-input').val());
	console.log(link_row);
	inserted = false;
	$('.link-row').each(function(){
		if($(this) != $(link_row)){
			other_rank = $(this).find('.rank-input').val();
			if(rank < other_rank && !inserted){
				console.log('reinserting this ting');
				$(link_row).insertBefore(this);
				console.log($(this));
				inserted = true;
			}
		}
	});
	if(inserted == false){
		$('.directory-tbody').append(link_row);
	}
}

rankLinkActions();

function editLinkActions(){
	$('.link-edit-link').unbind('click').click(function(){
		// alert("editing link");
		key = $(this).attr('id').split('-edit-link')[0];
		console.log(key);
		link_row = $('#'+key+'-row');
		$(link_row).find('.description-edit-input').toggle();
		$(link_row).find('.key-edit-input').toggle();
		$(link_row).find('.edit-tags-container').toggle();
		$(link_row).find('.tags-edit-input').toggle();
		$(link_row).find('.description-container').toggle();
		$(link_row).find('.tags-container').toggle();
		$(link_row).find('.edit-buttons').toggle();
	});
}
editLinkActions();

function deleteLinkActions(){
	$('.delete-link-btn').unbind('click').click(function(){
		key = $(this).attr('id');
		$('#spinner-div').show();
		$.ajax({
		      url: '/go/delete_link',
		      type: 'POST',
		      data: {'key': key + ':override'},
		      success:function(data){
		        $('#'+key+'-row').remove();
		        $('#spinner-div').hide();
		        // (data);
		      },
		      error:function (xhr, textStatus, thrownError){
		        console.log('unable to remove link');
		        $('#spinner-div').hide();
		      }
		  });

	});
}
deleteLinkActions();
function deleteTagActions(){
	$('.tag-delete-link').unbind('click').click(function(){
		$(this).parent().remove();
	});
}
deleteTagActions();

function stripText(text){
	return text.toLowerCase().replace(/[^a-zA-Z0-9 -]/g, '').replace(/ /g,'-');
}
function addTagActions(){
	$('.tags-edit-input').unbind('keypress').keypress(function(e) {
		key = $(this).attr('id').split('-tags-edit-input')[0];
		that = $(this).parent();
		if(e.which == 13) {
			tag = stripText($(this).val());
			$(this).val('');
			htmlTag = document.createElement('div');
	       $(htmlTag).addClass('label');
	       $(htmlTag).addClass('label-default');
	       $(htmlTag).addClass('edit-tag');
	       $(htmlTag).attr('id', key + ',' + tag)
	       $(htmlTag).text(tag);
	       $(htmlTag).append('&nbsp;<a class = "tag-delete-link" href = "javascript:void(0);">x</a>');
	       $(that).prepend(htmlTag);
	       deleteTagActions();
		}
	});
}
addTagActions();

function saveLinkActions(){
	$('.save-link-btn').unbind('click').click(function(){
		key = $(this).attr('id');
		newkey = $('#'+key+'-row').find('.key-edit-input').val();
		description = $('#'+key+'-row').find('.description-edit-input').val();
		tags = [];
		$('#'+key+'-row').find('.edit-tag').each(function(){
			tg = $(this).text();
			tags.push(tg.substring(0, tg.length-2));
		});
		tags = tags.join(',');

		console.log(tags);
		console.log(description);
		console.log(key);
		$('#spinner-div').show();
		$.ajax({
		      url: '/go/update_link',
		      type: 'POST',
		      data: {'key': key, 'description':description, 'tags': tags, 'newkey':newkey},
		      success:function(data){
		      	console.log('success saving');
		      	$('#'+key+'-row').html(data);
		        $('#spinner-div').hide();
		        // reinitialize js
		        // toggleTag
		      },
		      error:function (xhr, textStatus, thrownError){
		        console.log('unable to remove link');
		        $('#spinner-div').hide();
		      }
		  });
	});
}
saveLinkActions();
function toggleTagSelected(tag){
	if($(tag).hasClass('selected-tag')){
		$(tag).removeClass('selected-tag');
	}
	else{
		$(tag).addClass('selected-tag');
	}
}
$(".tag-cloud-tag").unbind('click').click(function(){
	toggleTagSelected($(this));
	filterGolinks();
});

$('.golink-tag').unbind('click').click(function(){
	tag = $(this).text();
	// tag = tag.substring(0, tag.length-2);
	toggleTagSelected($('#'+tag+'-tag'));
	filterGolinks();
});
