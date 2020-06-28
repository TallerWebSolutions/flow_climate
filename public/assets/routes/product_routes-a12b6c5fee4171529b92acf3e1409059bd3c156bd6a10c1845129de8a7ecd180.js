function getProductPortfolioUnitsTab(companyId, productId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/products/${productId}/portfolio_units_tab.js`,
        type: "GET"
    });
}

function getProjectsTab(companyId, productId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/products/${productId}/projects_tab.js`,
        type: "GET"
    });
}

function getPortfolioChartsTab(companyId, productId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/products/${productId}/portfolio_charts_tab.js`,
        type: "GET"
    });
}

function searchPortfolioChartsTab(companyId, productId, startDate, endDate, period) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/products/${productId}/portfolio_charts_tab.js`,
        type: "GET",
        data: `period=${period}&start_date=${startDate}&end_date=${endDate}`
    });
}

function getRiskReviewsTab(companyId, productId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/products/${productId}/risk_reviews_tab.js`,
        type: "GET"
    });
}

function getServiceDeliveryReviewsTab(companyId, productId) {
    $("#general-loader").show();

    jQuery.ajax({
        url: `/companies/${companyId}/products/${productId}/service_delivery_reviews_tab.js`,
        type: "GET"
    });
};
