function startEventPointChangeActions(){
	$('.event-points-input').focusout(function(){
		$(this).addClass("updating");
		//make ajax request
		event_id = $(this).attr('id').split('.')[0];
		points = $(this).val();
		path = '/events/'+event_id+'/update_points'
		that = $(this);
		successFunction = function (data){
			$(that).removeClass('updating');
			console.log($(that));
		}
		errorFunction = function(){
			alert("failed");
		}
		data = {'points': points}
		makeAjaxRequest(path, 'POST', data, successFunction, errorFunction);
	});
}
/**
* to be performed on page load
*/
$(document).ready(function(){
	startEventPointChangeActions();
});