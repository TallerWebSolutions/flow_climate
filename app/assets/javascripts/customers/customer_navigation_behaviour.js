const navItem = $(".nav-item");

hideAllComponents(navItem);

const stampsDiv = $("#nav-item-stamps");
stampsDiv.addClass("active");

$("#customer-stamps").show();

navItem.on("click", function(event){
    hideAllComponents(navItem);
    const disabled = $(this).attr("disabled");

    const companyId = $("#company_id").val();
    const customerId = $("#customer_id").val();

    if (disabled === "disabled") {
        event.preventDefault();

    } else {
        disableTabs();

        if ($(this).attr("id") === "nav-item-projects-table") {
            $(".col-table-details").hide();
            getProjectsTab(companyId, customerId)

        } else {
            enableTabs();
            $($(this).data("container")).show();
        }

        $(this).addClass("active");
    }
});
