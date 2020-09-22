function bindSlackConfigTypeSelect() {
    checkSlackConfigSelect($('#slack-config-type-select option:selected').val());

    $("#slack-config-type-select").on("change", function() {
        checkSlackConfigSelect(this.value)
    });
}

function checkSlackConfigSelect(slackConfigSelectValue) {
    if (slackConfigSelectValue === "demand_state_changed") {
        $("#stages-to-notify-div").show();
    } else {
        $("#stages-to-notify-div").hide();
    }
};
