function bindBlockFormModalAction() {
    bindBlockFormModalActionToSpecificElement($('.edit-block'));
}

function bindBlockFormModalActionToSpecificElement(element) {
    element.on('click', {} ,function(e){
        e.preventDefault();
        const $this = $(this);
        $("#edit-block-form").modal("toggle", $this);
    });
};
