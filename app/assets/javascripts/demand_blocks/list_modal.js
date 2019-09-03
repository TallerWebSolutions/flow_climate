$(document).on('click', '.list-block', {} ,function(e){
    e.preventDefault();
    let $this = $(this);
    $("#list-blocks-page").modal("toggle", $this);
});
