hideAllComponents();
$('#team-stamps').show();
$('#nav-item-stamps').addClass('active');

$('#nav-item-stamps').on('click', function(){
    hideAllComponents();
    $('#team-stamps').show();
    $('#nav-item-stamps').addClass('active');
});

$('#nav-item-list').on('click', function(){
    hideAllComponents();
    $('#project-list').show();
    $('#nav-item-list').addClass('active');
});

$('#nav-item-charts').on('click', function(){
    hideAllComponents();
    $('#team-charts').show();
    $('#nav-item-charts').addClass('active');
});

function hideAllComponents() {
    $('#team-stamps').hide();
    $('#project-list').hide();
    $('#team-charts').hide();

    $('#nav-item-stamps').removeClass('active');
    $('#nav-item-list').removeClass('active');
    $('#nav-item-charts').removeClass('active');
}