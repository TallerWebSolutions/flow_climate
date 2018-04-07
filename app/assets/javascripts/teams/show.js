hideAllComponents();
$('#stamps').show();
$('#nav-item-stamps').addClass('active');

$('#nav-item-stamps').on('click', function(){
    hideAllComponents();
    $('#stamps').show();
    $('#nav-item-stamps').addClass('active');
});

$('#nav-item-list').on('click', function(){
    hideAllComponents();
    $('#project-list').show();
    $('#nav-item-list').addClass('active');
});

$('#nav-item-charts').on('click', function(){
    hideAllComponents();
    $('#charts').show();
    $('#nav-item-charts').addClass('active');
});

$('#nav-item-strategic').on('click', function(){
    hideAllComponents();
    $('#strategic').show();
    $('#nav-item-strategic').addClass('active');
});

$('#nav-item-members').on('click', function(){
    hideAllComponents();
    $('#members-table').show();
    $('#nav-item-members').addClass('active');
});

$('#nav-item-flow').on('click', function(){
    hideAllComponents();
    $('#flow').show();
    $('#nav-item-flow').addClass('active');
});

$('#nav-item-settings').on('click', function(){
    hideAllComponents();
    $('#settings').show();
    $('#nav-item-settings').addClass('active');
});

function hideAllComponents() {
    $('#stamps').hide();
    $('#project-list').hide();
    $('#charts').hide();
    $('#strategic').hide();
    $('#members-table').hide();
    $('#settings').hide();
    $('#flow').hide();

    $('#nav-item-stamps').removeClass('active');
    $('#nav-item-list').removeClass('active');
    $('#nav-item-charts').removeClass('active');
    $('#nav-item-strategic').removeClass('active');
    $('#nav-item-members').removeClass('active');
    $('#nav-item-settings').removeClass('active');
    $('#nav-item-flow').removeClass('active');
}

function openTab(evt, tabName) {
    var i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
    }
    document.getElementById(tabName).style.display = "block";
    evt.currentTarget.className += " active";
}

var acc = document.getElementsByClassName("accordion");
var i;

for (i = 0; i < acc.length; i++) {
    acc[i].addEventListener("click", function() {
        this.classList.toggle("active");
        var panel = this.nextElementSibling;
        if (panel.style.display === "block") {
            panel.style.display = "none";
        } else {
            panel.style.display = "block";
        }
    });
}
