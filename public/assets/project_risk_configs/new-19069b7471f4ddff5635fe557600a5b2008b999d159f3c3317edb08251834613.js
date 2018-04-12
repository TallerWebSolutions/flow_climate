hideAllExplanations();

var select_risk_type = $('#select_risk_type');
select_risk_type.on('change', function() {
    hideAllExplanations();
    var selected_risk = select_risk_type.val();
    if (selected_risk === "no_money_to_deadline") {
        $('#no_money_to_deadline').show();
    } else if (selected_risk === "backlog_growth_rate") {
        $('#backlog_growth_rate').show();
    } else if (selected_risk === "not_enough_available_hours") {
        $('#not_enough_available_hours').show();
    } else if (selected_risk === "profit_margin") {
        $('#profit_margin').show();
    } else if (selected_risk === "flow_pressure") {
        $('#flow_pressure').show();
    }
});

function hideAllExplanations() {
    $('#no_money_to_deadline').hide();
    $('#backlog_growth_rate').hide();
    $('#not_enough_available_hours').hide();
    $('#profit_margin').hide();
    $('#flow_pressure').hide();
}
;
