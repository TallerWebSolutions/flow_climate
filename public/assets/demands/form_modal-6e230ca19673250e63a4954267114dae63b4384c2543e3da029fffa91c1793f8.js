$(document).on('click', '.edit-demand-button', {} ,function(e) {
    e.preventDefault();

    $("#edit-demand-form").modal({
        backdrop: 'static',
        keyboard: false
    });
});

function monteCarloDialog(companyId, demandsIds) {
    event.preventDefault();

    $("#show-montecarlo-dialog").modal({
        backdrop: 'static',
        keyboard: false
    });

    getMonteCarloComputation(companyId, demandsIds);
};
