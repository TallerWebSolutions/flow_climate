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

function hideAllComponents() {
    $('#stamps').hide();
    $('#project-list').hide();
    $('#charts').hide();
    $('#strategic').hide();
    $('#members-table').hide();

    $('#nav-item-stamps').removeClass('active');
    $('#nav-item-list').removeClass('active');
    $('#nav-item-charts').removeClass('active');
    $('#nav-item-strategic').removeClass('active');
    $('#nav-item-members').removeClass('active');
}