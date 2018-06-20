function disableTabs() {
    $('.loader').show();
    $('.nav-item').attr('disabled', 'disabled');
}

function enableTabs() {
    $(".loader").hide();
    $('.nav-item').removeAttr('disabled');
}
