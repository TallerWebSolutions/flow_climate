$(document).on('click', '.edit-demand-button', {} ,function(e){
    e.preventDefault();
    const $this = $(this);
    $("#edit-demand-form").modal("toggle", $this);
});
