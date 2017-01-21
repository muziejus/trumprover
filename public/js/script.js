$( "#inputUrl" ).change(function() {
  if(!$( "#inputUrl" ).val().match(/twitter.com.(POTUS|therealdonaldtrump).status./i)) {
    $( "#urlForm" ).removeClass("has-success").addClass("has-feedback").addClass("has-error");
    $( "#urlFormLabel" ).text("This doesn’t look like a URL for a tweet by Donald Trump.");
  } else {
    $( "#urlForm" ).removeClass("has-error").addClass("has-success").addClass("has-feedback");
    $( "#urlFormLabel" ).text("Looks like a Donald Trump tweet!");
  }

});
  
