/* Project specific Javascript goes here. */

function readURL(input) {

  if (input.files && input.files[0]) {
    console.log("FIRST", input.files);
    console.log("SECOND", input.files[0])

    var reader = new FileReader();

    reader.onload = function(e) {
      $('.image-upload-wrap').hide();
      console.log("TARGET", e)
      $('.file-upload-image').attr('src', e.target.result);
      $('.file-upload-content').show();
      $('.image-title').html(input.files[0].name);
    };
    console.log("INPUT", input.files[0])
    reader.readAsDataURL(input.files[0]);

  } else {
    removeUpload();
  }
}

function removeUpload() {
  $('.file-upload-input').replaceWith($('.file-upload-input').clone());
  $('.file-upload-content').hide();
  $('.image-upload-wrap').show();
}
$('.image-upload-wrap').bind('dragover', function () {
    $('.image-upload-wrap').addClass('image-dropping');
  });
  $('.image-upload-wrap').bind('dragleave', function () {
    $('.image-upload-wrap').removeClass('image-dropping');
});

$('body').append('<div id="loadingDiv"><div class="loader">Loading...</div></div>');

function addLoader(){
    $('body').append('<div id="loadingDiv"><div class="loader">Loading...</div></div>');
}

$(window).on('load', function(){
  setTimeout(removeLoader, 500); //wait for page load PLUS half a seconds.
});


function removeLoader(){
    $( "#loadingDiv" ).fadeOut(500, function() {
      // fadeOut complete. Remove the loading div
      $( "#loadingDiv" ).remove(); //makes page more lightweight
      });
//      scrollToMe();
//      setTimeout(scrollToTop, 1000);
      }

function scrollToTop(){
    window.scrollTo(0,0);
}

function scrollToMe(){
    document.querySelector('#download-box').scrollIntoView({
        behavior: 'smooth'
    });
}

function afterSubmit(){
    var aa = $('.sharpen-btn');
    console.log(aa);
    addLoader();
    }

function show() {
    $('.image-upload-wrap').attr("style","display: none;");
    $('.file-upload-content').attr("style","display: block;");
    $('.file-upload-image').attr("src","media/sample/dancing.jpg");
}

//function myReadURL(image) {
//    $('.image-upload-wrap').hide();;
//    $('.file-upload-content').show();;
//    var bb = image.src;
//    console.log("SRC IS:", bb)
//
//    $('.file-upload-image').attr("src",bb);
////    $('.file-upload-input').attr("src",bb);
//    var aa = $('#id_image');
//
//    let list = new DataTransfer();
//    let file = new File([bb], "albert_einstein.jpg", {type:"image/jpeg", lastModified:new Date().getTime()});
//    list.items.add(file);
//    let myFileList = list.files;
//    aa[0].files = myFileList;
//    console.log("FGGRDS", aa[0].files[0])
//
//    var reader = new FileReader();
//    reader.readAsDataURL(aa[0].files[0]);
//
//}
