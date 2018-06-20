function disableTabs() {
    $(".loader").show();

    var navitem = $('.nav-item');
    navitem.attr("disabled", true);
    navitem.off('click');
}

function enableTabs() {
    $(".loader").hide();

    var navitem = $('.nav-item');
    navitem.attr("disabled", false);
    navitem.on('click')
}
