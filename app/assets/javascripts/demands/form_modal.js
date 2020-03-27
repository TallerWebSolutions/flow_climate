$(document).on('click', '.edit-demand-button', {} ,function(e) {
    e.preventDefault();

    $("#edit-demand-form").modal({
        backdrop: 'static',
        keyboard: false
    });
});

$(document).on('click', '.show-montecarlo-dialog', {} ,function(e) {
    e.preventDefault();

    $("#show-montecarlo-dialog").modal({
        backdrop: 'static',
        keyboard: false
    });
});
