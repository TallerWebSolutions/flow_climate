$('#demands-grouped-per-month-div').hide();
$('#demands-grouped-per-customer-div').hide();

var companyId = $("#company_id").val();
var teamId = $("#team_id").val();

$('.filter-checks').on('change', function(){
    var flatDemands = $('#grouping_no_grouping').is(":checked");
    var groupedByMonth = $('#grouping_grouped_per_month').is(":checked");
    var groupedByCustomer = $('#grouping_grouped_per_customer').is(":checked");

    var notStarted = $('#searching_not_started').is(":checked");
    var committed = $('#searching_work_in_progress').is(":checked");
    var delivered = $('#searching_delivered_demands').is(":checked");

    searchDemandsByFlowStatus(companyId, teamId, flatDemands, groupedByMonth, groupedByCustomer, notStarted, committed, delivered)
});
