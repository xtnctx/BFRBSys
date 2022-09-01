/* JQuery - AJAX */
// Prevents page reload when submitting form
$(document).on('submit', '#login-form', function(e) {
    loginURL = "{% url 'login' %}"
    e.preventDefault();

    $.ajax({
    type: 'POST',
    url: 'login/',
    data: {
        username: $('#username').val(),
        password: $('#password').val(),
        nextURL: $('#nextURL').val(),
        csrfmiddlewaretoken: $('input[name=csrfmiddlewaretoken]').val()
    },

    // GET response
    error: function (response) {
        $('#status-div').css('grid-template-columns', '1fr')
        $('#status-message').css('color', 'red');
        $('#status-message').text(response.responseJSON.error);
    },

    success: function(response) {
        $('#status-div').css('grid-template-columns', '4fr 1fr')
        $('#status-message').css('color', 'green');
        $('#status-message').text(response.success);
        reloadPage();
    }

    });


    function delay(delayInms) {
        return new Promise(resolve => {
          setTimeout(() => {
            resolve(2);
          }, delayInms);
        });
    }

    async function reloadPage() {
        $('#loader').show();
        let delayres = await delay(2000);
        location.reload();
    }
    

  })


// Prevent dropdown menu from closing when click inside the form
$(document).on("click", ".action-buttons .dropdown-menu", function(e){
    e.stopPropagation();
});