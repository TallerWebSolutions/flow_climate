$(document).on('click', '.list-block', {} ,function(e){
    e.preventDefault();
    $("#list-blocks-page").modal({
        backdrop: 'static',
        keyboard: false
    });
});
