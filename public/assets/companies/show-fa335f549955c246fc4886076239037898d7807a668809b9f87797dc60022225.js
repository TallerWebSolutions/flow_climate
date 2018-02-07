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

$('#nav-item-finance').on('click', function(){
    hideAllComponents();
    $('#finance').show();
    $('#nav-item-finance').addClass('active');
});

$('#nav-item-teams').on('click', function(){
    hideAllComponents();
    $('#teams').show();
    $('#nav-item-teams').addClass('active');
});

$('#nav-item-strategic').on('click', function(){
    hideAllComponents();
    $('#strategic').show();
    $('#nav-item-strategic').addClass('active');
});

$('#nav-item-settings').on('click', function(){
    hideAllComponents();
    $('#settings').show();
    $('#nav-item-settings').addClass('active');
});

function hideAllComponents() {
    $('#stamps').hide();
    $('#project-list').hide();
    $('#finance').hide();
    $('#strategic').hide();
    $('#settings').hide();
    $('#teams').hide();

    $('#nav-item-stamps').removeClass('active');
    $('#nav-item-list').removeClass('active');
    $('#nav-item-finance').removeClass('active');
    $('#nav-item-strategic').removeClass('active');
    $('#nav-item-settings').removeClass('active');
    $('#nav-item-teams').removeClass('active');
}
;
