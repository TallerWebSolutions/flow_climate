$(document).on('click', '.list-block', {} ,function(e){
    e.preventDefault();
    var $this = $(this);
    $("#list-blocks-page").modal("toggle", $this);
});
