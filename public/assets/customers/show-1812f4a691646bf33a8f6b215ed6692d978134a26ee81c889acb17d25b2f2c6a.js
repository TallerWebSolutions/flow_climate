hideAllComponents($('.nav-item'));
$('#stamps').show();
$('#nav-item-stamps').addClass('active');

$('#nav-item-stamps').on('click', function(){
    hideAllComponents($('.nav-item'));
    $('#stamps').show();
    $('#nav-item-stamps').addClass('active');
});

$('#nav-item-list').on('click', function(){
    hideAllComponents($('.nav-item'));
    $('#project-list').show();
    $('#nav-item-list').addClass('active');
});
