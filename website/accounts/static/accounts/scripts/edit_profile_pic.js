
const img = document.getElementById("inputfile");
const imagePreview = document.getElementById("imagePreview");

img.addEventListener("change", (e) => {
    const imgDetails = document.querySelector("input[type=file]").files[0];
    if (imgDetails) {
        previewImage(imgDetails);
    } else {
        imagePreview.src = ""
        console.error("Please select a picture");
    }

})

function previewImage(imgD) {
    const reader = new FileReader();

    // PREVIEW
    reader.addEventListener("load", function () {
        imagePreview.src = reader.result;
    })

    // CHECK IF THERE IS SELECTION 
    if (imgD) {
        // CHECK IF THE FILE IS AN IMAGE
        if (imgD.type === "image/jpeg" || imgD.type == "image/jpg" || imgD.type == "image/gif" || imgD.type == "image/png") {
            // CONVERTS FILE TO BASE 64
            reader.readAsDataURL(imgD);
        } else {
            imagePreview.src = "";
        }
    }
    // IF NO IMAGE
    else {
        imagePreview.src = ""
    }
}