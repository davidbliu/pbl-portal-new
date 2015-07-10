$(document).ready(function(){
//get current tab url
chrome.tabs.getSelected(null,function(tab) {
    	$('#url-input').val(tab.url);
});


// Create the XHR object.
function createCORSRequest(method, url) {
  var xhr = new XMLHttpRequest();
  if ("withCredentials" in xhr) {
    // XHR for Chrome/Firefox/Opera/Safari.
    xhr.open(method, url, true);
  } else if (typeof XDomainRequest != "undefined") {
    // XDomainRequest for IE.
    xhr = new XDomainRequest();
    xhr.open(method, url);
  } else {
    // CORS not supported.
    xhr = null;
  }
  return xhr;
}

$("#save").click(function(){
	$('#message').text('Saving link...');
	$('#message2').text('');
	key = $('#key-input').val();
	url = $('#url-input').val();
	description = $('#description-input').val();
	directory = $('#directory-input').val();
	
	params = "key="+key+"&url="+encodeURIComponent(url)+"&description="+encodeURIComponent(description)+"&directory="+encodeURIComponent(directory);


	url = 'http://testing.berkeley-pbl.com/go/create' + '?' + params
  var xhr = createCORSRequest('POST', url);
  if (!xhr) {
    $('#message2').text('CORS not supported');
    return;
  }
  // Response handlers.
  xhr.onload = function() {
    var text = xhr.responseText;
    $('#message').text(text);
    $('#message2').text('Visit link at pbl.link/'+key);
  };

  xhr.onerror = function() {
  	var text = xhr.responseText;
    $('#message').text('Error: unable to save link');
  };

  xhr.send();




	
});

});
