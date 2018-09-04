$(document).on('click', '.edit-block', {} ,function(e){
    e.preventDefault();
    const $this = $(this);
    $("#edit-block-form").modal("toggle", $this);
});
