function getProjectsTab(companyId, customerId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/customers/${customerId}/projects_tab.js`,
        type: "GET"
    });
}
