hideAllComponents();
$('#project-stamps').show();
$('#nav-item-stamps').addClass('active');

$('#nav-item-stamps').on('click', function(){
    hideAllComponents();
    $('#project-stamps').show();
    $('#nav-item-stamps').addClass('active');
});

$('#nav-item-results').on('click', function(){
    hideAllComponents();
    $('#project-results').show();
    $('#nav-item-results').addClass('active');
});

$('#nav-item-delivered').on('click', function(){
    hideAllComponents();
    $('#delivered-demands').show();
    $('#nav-item-delivered').addClass('active');
});

$('#nav-item-charts').on('click', function(){
    hideAllComponents();
    $('#project-charts').show();
    $('#nav-item-charts').addClass('active');
});

$('#nav-item-risk').on('click', function(){
    hideAllComponents();
    $('#project-risk-alerts-table').show();
    $('#nav-item-risk').addClass('active');
});

$('#nav-item-settings').on('click', function(){
    hideAllComponents();
    $('#project-settings').show();
    $('#nav-item-settings').addClass('active');
});

$('#nav-item-deadline').on('click', function(){
    hideAllComponents();
    $('#deadline-change').show();
    $('#nav-item-deadline').addClass('active');
});

function hideAllComponents() {
    $('#project-stamps').hide();
    $('#nav-item-stamps').removeClass('active');
    $('#project-results').hide();
    $('#nav-item-results').removeClass('active');
    $('#delivered-demands').hide();
    $('#nav-item-delivered').removeClass('active');
    $('#project-risk-alerts-table').hide();
    $('#nav-item-charts').removeClass('active');
    $('#project-charts').hide();
    $('#nav-item-risk').removeClass('active');
    $('#project-settings').hide();
    $('#nav-item-settings').removeClass('active');
    $('#deadline-change').hide();
    $('#nav-item-deadline').removeClass('active');
}