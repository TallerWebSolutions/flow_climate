function bindBlockFormModalAction() {
    bindBlockFormModalActionToSpecificElement($('.edit-block'));
}

function bindBlockFormModalActionToSpecificElement(element) {
    element.on('click', {} ,function(e){
        e.preventDefault();
        const $this = $(this);
        $('#edit-block-form').modal('show');
        // $("#edit-block-form").modal({
        //     backdrop: 'static',
        //     keyboard: false
        // });
    });
}


$(window).load(function() {
    $('#prizePopup').modal('show');
});
