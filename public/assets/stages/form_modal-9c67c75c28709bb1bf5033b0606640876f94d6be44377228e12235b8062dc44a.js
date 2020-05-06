$(document).on('click', '.edit-stage', {} ,function(e){
    e.preventDefault();
    $("#edit-stage-form").modal({
        backdrop: 'static',
        keyboard: false
    });
});
