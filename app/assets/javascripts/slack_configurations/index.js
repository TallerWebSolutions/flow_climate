function bindSlackConfigTypeSelect() {
    checkSlackConfigSelect($('#slack-config-type-select option:selected').val());

    $("#slack-config-type-select").on("change", function() {
        checkSlackConfigSelect(this.value)
    });
}

function checkSlackConfigSelect(slackConfigSelectValue) {
    console.log(slackConfigSelectValue);

    if (slackConfigSelectValue.value === "demand_state_changed") {
        $("#stages-to-notify-div").show();
    } else {
        $("input[type=checkbox]").prop("checked", false);
        $("#stages-to-notify-div").hide();
    }
}