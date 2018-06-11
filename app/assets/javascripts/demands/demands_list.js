$('#demands-grouped-per-month-div').hide();
$('#demands-grouped-per-customer-div').hide();

var companyId = $("#company_id").val();
var teamId = $("#team_id").val();

$('#demands-grouped-by-month-check').on('change', function(){
    console.log('grouped month');
    if($(this).is(":checked")) {
        $('#demands-grouped-per-month-div').show();
        $('#demands-grouped-per-customer-div').hide();
        $('#flat-demands-div').hide();
        $('#demands-grouped-by-customer-check').prop('checked', false);
        $('#demands-no-grouping-check').prop('checked', false);
    }
});

$('#demands-grouped-by-customer-check').on('change', function(){
    if($(this).is(":checked")) {
        $('#demands-grouped-per-customer-div').show();
        $('#demands-grouped-per-month-div').hide();
        $('#flat-demands-div').hide();
        $('#demands-grouped-by-month-check').prop('checked', false);
        $('#demands-no-grouping-check').prop('checked', false);
    }
});

$('#demands-no-grouping-check').on('change', function(){
    if($(this).is(":checked")) {
        $('#demands-grouped-per-customer-div').hide();
        $('#demands-grouped-per-month-div').hide();
        $('#flat-demands-div').show();
        $('#demands-grouped-by-month-check').prop('checked', false);
        $('#demands-grouped-by-customer-check').prop('checked', false);
    }
});

$('#demands-not-started-check').on('change', function(){
    searchDemandsByFlowStatus(companyId, teamId, true, false, false)
});
