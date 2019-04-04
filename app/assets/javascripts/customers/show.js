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

function hideAllComponents() {
    $('#stamps').hide();
    $('#project-list').hide();

    $('#nav-item-stamps').removeClass('active');
    $('#nav-item-list').removeClass('active');
    $('#nav-item-statusreport').removeClass('active');
    $('#nav-item-charts').removeClass('active');
}