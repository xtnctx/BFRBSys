/* ############ Sidebar ############*/

var navLinks = document.getElementById("navLinks");
var hideIcon = document.getElementById("hideIcon");

var sidebarActive = false


function hideMenu() {
    navLinks.style.right = "-120px"
    enableScrolling()
    sidebarActive = false
}

function showMenu() {
    navLinks.style.right = "0"
    hideIcon.style.margin = "0"
    disableScrolling()
    sidebarActive = true
}



/* ############ NavContainer ############*/

// Hides navbar:
//     when scrolling down
//     when inactive
 
// Shows navbar:
//     when scrolling up
//     in given threshold

function disableScrolling(){
    var x=window.scrollX;
    var y=window.scrollY;
    window.onscroll= ()=> { window.scrollTo(x, y) };
}

function enableScrolling(){
    window.onscroll= ()=> {};
}

const nav = document.getElementById('navbar')
let lastScrollY = window.scrollY
const threshold = 20

window.addEventListener('scroll', ()=> {
    
    if (lastScrollY < window.scrollY) {
        nav.classList.add('nav-hidden')
    } else {
        nav.classList.remove('nav-hidden')
    }

    if (lastScrollY <= threshold) nav.classList.remove('nav-hidden')

    lastScrollY = window.scrollY
})


function inactivityTime() {
    var time;
    window.onload = resetTimer;
    // DOM Events
    document.onkeydown = resetTimer;
    document.addEventListener('scroll', resetTimer, true)

    function hideItem() {
        if (lastScrollY !== 0 && !sidebarActive) nav.classList.add('nav-hidden')
        if (lastScrollY <= threshold) nav.classList.remove('nav-hidden')
    }

    function resetTimer() {
        clearTimeout(time);
        time = setTimeout(hideItem, 3000)
        nav.classList.remove('nav-hidden')
        
    }
};


window.onload = ()=> {
    inactivityTime()
  }