const navItemStamps = $("#nav-item-stamps");
const navItemPortfolio = $("#nav-item-portfolio-unit");
const navItemList = $("#nav-item-list");

hideAllComponents();

$("#stamps").show();

navItemStamps.addClass("active");

navItemStamps.on("click", function(){
    hideAllComponents();
    $("#stamps").show();
    $("#nav-item-stamps").addClass("active");
});
navItemList.on("click", function(){
    hideAllComponents();
    $("#project-list").show();
    $("#nav-item-list").addClass("active");
});

navItemPortfolio.on("click", function(){
    hideAllComponents();
    $("#portfolio-units").show();
    $("#nav-item-portfolio-unit").addClass("active");
});

function hideAllComponents() {
    $(".tab-detail").hide();
    $(".nav-tab").removeClass("active");
}
