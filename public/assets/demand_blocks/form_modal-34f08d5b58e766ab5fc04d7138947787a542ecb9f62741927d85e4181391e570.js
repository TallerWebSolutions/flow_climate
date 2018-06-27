$(document).on('click', '.edit-block', {} ,function(e){
    e.preventDefault();
    var $this = $(this);
    $("#edit-block-form").modal("toggle", $this);
});
