function getProjectBlocks(companyId, projectId, startDate, endDate) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/projects/${projectId}/demands_blocks_tab.js`,
        type: "GET",
        data: `start_date=${startDate}&end_date=${endDate}`
    });
}

function getFlowImpacts(companyId, projectId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/projects/${projectId}/flow_impacts/flow_impacts_tab.js`,
        type: "GET"
    });
}
