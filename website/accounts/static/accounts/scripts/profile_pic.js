document.querySelector("html").classList.add('js');

//declearing html elements

const imgDiv = document.querySelector('.image-container');
const img = document.querySelector('#photo');
const file = document.querySelector('.input-file');
const uploadBtn = document.querySelector('#uploadBtn');

// init our variables
var fileInput = document.querySelector( ".input-file" ),
	button = document.querySelector( ".input-file-trigger" );


//if user hover on img div 

imgDiv.addEventListener('mouseenter', function(){
    uploadBtn.style.display = "block";
});

//if we hover out from img div

imgDiv.addEventListener('mouseleave', function(){
    uploadBtn.style.display = "none";
});

file.addEventListener('change', function(){
    //this refers to file
    const choosedFile = this.files[0];

    if (choosedFile) {

        const reader = new FileReader();

        reader.addEventListener('load', function(){
            img.setAttribute('src', reader.result);
        });

        console.log(choosedFile.name);

        reader.readAsDataURL(choosedFile);
    }
});


// Trigger when Space bar or Enter is hit
button.addEventListener( "keydown", function( event ) {
	if ( event.keyCode == 13 || event.keyCode == 32 ) {
		fileInput.focus();
	}
});

// Trigger when the label is clicked
button.addEventListener( "click", function( event ) {
	fileInput.focus();
	return false;
});
