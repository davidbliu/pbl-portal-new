function filterGolinks(){
	$('.link-row').each(function(){
		$(this).show();
	});
	selected_tags = [];
	$('.tag-cloud-tag').each(function(){
		if($(this).hasClass('selected-tag')){
			selected_tags.push($(this).attr('id'));
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
					break;
				}
			}
		});
	}
}

function rankLinkActions(){
	$('.rank-input').keypress(function(e) {
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
$(".tag-cloud-tag").click(function(){
	if($(this).hasClass('selected-tag')){
		$(this).removeClass('selected-tag');
	}
	else{
		$(this).addClass('selected-tag');
	}
	filterGolinks();
});

