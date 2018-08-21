$(document).on('click', '.statistics-project', {} ,function(e){
    e.preventDefault();
    var $this = $(this);
    $("#project-statistics-page").modal("toggle", $this);
});
