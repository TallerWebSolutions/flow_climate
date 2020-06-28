function getDemandBlocksForProjects(companyId, projectsIds) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/demand_blocks/demand_blocks_tab.js`,
        type: "GET",
        data: `projects_ids=${projectsIds}`
    });
};
