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

$(".tag-cloud-tag").click(function(){
	if($(this).hasClass('selected-tag')){
		$(this).removeClass('selected-tag');
	}
	else{
		$(this).addClass('selected-tag');
	}
	filterGolinks();
});

