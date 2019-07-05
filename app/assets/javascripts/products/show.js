const navItemStamps = $("#nav-item-stamps");
const navItemPortfolio = $("#nav-item-portfolio-unit");
const navItemList = $("#nav-item-list");
const navItemSettings = $("#nav-item-product-settings");

hideAllComponents();

$("#stamps").show();

navItemStamps.addClass("active");

navItemStamps.on("click", function(){
    hideAllComponents();
    $("#stamps").show();
    navItemStamps.addClass("active");
});
navItemList.on("click", function(){
    hideAllComponents();
    $("#project-list").show();
    navItemList.addClass("active");
});

navItemPortfolio.on("click", function(){
    hideAllComponents();
    $("#portfolio-units").show();
    navItemPortfolio.addClass("active");
});

navItemSettings.on("click", function(){
    hideAllComponents();
    $("#product-settings-content").show();
    navItemSettings.addClass("active");
});

function hideAllComponents() {
    $(".tab-detail").hide();
    $(".nav-tab").removeClass("active");
}
