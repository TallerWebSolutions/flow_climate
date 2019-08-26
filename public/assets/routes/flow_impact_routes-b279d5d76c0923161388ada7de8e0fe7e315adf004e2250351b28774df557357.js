function getProjectFlowImpacts(companyId, projectId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/projects/${projectId}/flow_impacts/flow_impacts_tab.js`,
        type: "GET"
    });
}
;
