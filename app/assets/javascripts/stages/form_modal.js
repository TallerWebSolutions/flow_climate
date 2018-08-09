$(document).on('click', '.edit-stage', {} ,function(e){
    e.preventDefault();
    var $this = $(this);
    $("#edit-stage-form").modal("toggle", $this);
});