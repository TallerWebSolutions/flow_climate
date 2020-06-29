function disableTabs() {
    $('#general-loader').show();
    $('.nav-item').attr('disabled', 'disabled');
}

function enableTabs() {
    $("#general-loader").hide();
    $('.nav-item').removeAttr('disabled');
};
