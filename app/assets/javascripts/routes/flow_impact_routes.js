function getFlowImpacts(companyId, projectsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/flow_impacts/flow_impacts_tab.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}`
    });
}
