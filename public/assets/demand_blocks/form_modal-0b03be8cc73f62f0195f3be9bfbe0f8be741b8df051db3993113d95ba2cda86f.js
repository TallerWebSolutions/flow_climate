function bindBlockFormModalAction() {
    bindBlockFormModalActionToSpecificElement($('.edit-block'));
}

function bindBlockFormModalActionToSpecificElement(element) {
    element.on('click', {} ,function(e){
        e.preventDefault();
        const $this = $(this);
        jQuery.noConflict();
        $("#edit-block-form").modal({
            backdrop: 'static',
            keyboard: false
        });
    });
};
