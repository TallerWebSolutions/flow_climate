function getUserDashboardCompanyTab(userId, companyId) {
    $("#user-dashboard-tab").hide();
    $("#general-loader").show();

    jQuery.ajax({
        url: `/users/${userId}/user_dashboard_company_tab.js`,
        type: "GET",
        data: `company_id=${companyId}`
    });
};
