var clicking = false;
var slots = {};
slots["0"] = [];
slots["1"] = [];
slots["2"] = [];
slots["3"] = [];
slots["4"] = [];
slots["5"] = [];
slots["6"] = [];
var days = ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"];
var hours = ["8", "9", "10", "11", "12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"];
function drawDays(){
	for(var i=0;i<days.length;i++){
		var day_div = document.createElement("div");
		$(day_div).addClass("day");
		$(day_div).attr("id", (i).toString());
		// $(day_div).text(days[i]);
		var header = document.createElement("div");
		$(header).addClass("day_header");
		$(header).text(days[i]);
		$(day_div).append(header);
		for(var j=0;j<hours.length-1;j++){
			var hour = document.createElement("div");
			$(hour).addClass("hour");
			$(hour).attr("id", j+8);
			$(hour).text(hours[j]+" - "+hours[j+1]);
			$(day_div).append(hour);
		}
		$("#times").append(day_div);
	}
}
function hourActions(){
	$(".hour").click(function(){
		toggleSelected($(this));
	});
}
function markSlots(marked_slots){
	for(var i=0;i<7;i++){
		var key = i;
		for(var j=0;j<marked_slots[key].length;j++){
			hour = marked_slots[key][j];
			var h = $("#"+key+" "+"#"+hour);
			toggleSelected(h);
		}
	}
}
function clearActions(){
	$("#clear-button").click(function(){
		$(".tracked_member").each(function(){
			$(this).remove();
			updateTrackedChart()
		});
	});
	;
}
function toggleSelected(thiss){

	if(! $(thiss).hasClass("selected")){
		$(thiss).addClass("selected");
		$(thiss).css("background-color", "rgb(129, 129, 127)");
		var d = $(thiss).parent().attr("id");
		var h = $(thiss).attr("id");
		slots[d].push(h);
	}
	else{
		$(thiss).css("background-color", "white");
		$(thiss).removeClass("selected");
		// remove this hour from slots
		var d = $(thiss).parent().attr("id");
		var h = $(thiss).attr("id");
		var index = slots[d].indexOf(h);
		if(index>-1){
			slots[d].splice(index,1);
		}
	}
}
function clickingActions(){
	$(".hour").click(function(){
		toggleSelected($(this));
	});
	$(".hour").mousedown(function(){
		clicking = true;
		toggleSelected($(this));
	});
	$(".hour").on("mouseover", function(){
		if(clicking == true){
			toggleSelected($(this));
		}
	});
	$(document).mouseup(function(){
		clicking = false;
	});
}
function submitCommitments(){
	alert("submitting your updated commitments");
	$.ajax({
      url:'/commitments/update_commitments',
      type: "GET",
      data: {"slots": slots}
  	}).done(function(data){
  		location.reload();
  	}).fail(function(data){
  		alert('failed');
  	});
}

function drawCMTable(){
	for(var i=0;i<days.length;i++){
		var day_div = document.createElement("div");
		$(day_div).addClass("day");
		$(day_div).attr("id", (i).toString());
		// $(day_div).text(days[i]);
		var header = document.createElement("div");
		$(header).addClass("day_header");
		$(header).text(days[i]);
		$(day_div).append(header);
		for(var j=0;j<hours.length-1;j++){
			var hour = document.createElement("div");
			$(hour).addClass("hour");
			$(hour).attr("id", j+8);
			$(hour).text(hours[j]+" - "+hours[j+1]);
			$(hour).css("background-color", "rgba(0, 0, 0, 0)");
			$(day_div).append(hour);
		}
		$("#cm_chart").append(day_div);
	}
}
$(document).ready(function(){

	drawDays();
	hourActions();
	clickingActions();
	$("#save_commitments").click(function(){
		submitCommitments();
	});
	if(marked_slots){
		markSlots(marked_slots);
	}
	console.log('completed startup actions')
	// drawCMTable();
	// updateTrackedChart();
	// startAutocomplete();
	// startTrackedActions();
	// clearActions();

});

function startTrackedActions(){
	$(".tracked_member").click(function(){
		$(this).remove();
		updateTrackedChart();
	});
}
function updateTrackedChart(){
	unmarkAll();
	// loop through the members in tracked
	$(".tracked_member").each(function(){
		var commitments = pbl_commitments[$(this).attr("id")];
		// console.log($(this).attr("id")+ " was the id");
		// console.log(commitments);
		if(commitments){
			for(var i=0;i<commitments.length;i++){
				var c = commitments[i];
				var h = $("#cm_chart").find(c);
				makeDarker(h);
				old_title = $(h).attr("title");
				new_title = old_title + ", "+reverse_member_hash[$(this).attr("id")];
				$(h).attr("title", new_title);
			}
		}
	});

}
function makeDarker(selection){
	var color = $(selection).css('background-color');
	var lastComma = color.lastIndexOf(',');
	var lastOpacity = color.slice(lastComma+1, color.length-1);
	var newOpacity = parseFloat(lastOpacity)+0.2;
	// var newOpacity = 1
	var newColor = color.slice(0, lastComma + 1) +newOpacity + ")";
	$(selection).css("background-color", newColor);
}

function unmarkAll(){
	$("#cm_chart").find(".hour").each(function(){
		$(this).css("background-color", "rgba(0,0,0,0)");
		$(this).attr("title", "");
	});
}

function startAutocomplete(){
	$("#member_search").autocomplete({
		source: member_names,
		select: function(event, ui){
			// alert(ui.item.value + " "+member_hash[ui.item.value]);
			var div = document.createElement("div");
			$(div).addClass("tracked_member");
			$(div).attr("id", member_hash[ui.item.value]);
			$(div).text(ui.item.value);
			$("#tracked_list").prepend(div);
			updateTrackedChart();
			startTrackedActions();
			$(this).val("");
		}
	})
}