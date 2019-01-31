hideAllComponents();

function activateTab() {
    $('.nav-item').on('click', function(){
        hideAllComponents();

        enableTabs();
        $($(this).data('container')).show();
        $(this).addClass('active');

        if ($(this).attr('id') === 'nav-item-risks') {
            const hoursGauge = $('#hours-gauge');
            buildGaugeChart(hoursGauge);
            buildStrategicHighcharts();
        } else if ($(this).attr('id') === 'nav-item-finance') {

        }
    });
}

function hideAllComponents() {
    $('.tab-container').hide();
    $('.nav-item').removeClass('active');
}
