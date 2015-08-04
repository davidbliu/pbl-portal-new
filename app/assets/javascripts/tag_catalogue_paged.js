function showSpinner(){
	$('#loading-gif').show();
}
function hideSpinner(){
	$('#loading-gif').hide();
}
$('.label').click(function(){
	showSpinner()
	tag = $(this).attr('id');
	index = selected_tags.indexOf(tag);
	if(index != -1){
		selected_tags.splice(index, 1);
	}
	else{
		selected_tags.push(tag);
	}
	window.location = '/go/tags?tags='+encodeURIComponent(selected_tags.join(','));
});
