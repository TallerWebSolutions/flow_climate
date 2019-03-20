function getCompanyProjectsTab(companyId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/projects_tab.js`,
        type: "GET"
    });
}

function getRisksTab(companyId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/risks_tab.js`,
        type: "GET"
    });
}

function getStrategicChartsTab(companyId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/strategic_chart_tab.js`,
        type: "GET"
    });
}
