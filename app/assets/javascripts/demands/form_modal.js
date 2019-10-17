$(document).on('click', '.edit-demand-button', {} ,function(e){
    e.preventDefault();
    $("#edit-demand-form").modal({
        backdrop: 'static',
        keyboard: false
    });
});
