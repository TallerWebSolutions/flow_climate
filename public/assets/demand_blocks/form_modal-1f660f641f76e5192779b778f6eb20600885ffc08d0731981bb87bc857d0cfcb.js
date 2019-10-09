function bindBlockFormModalAction() {
    $('.edit-block').on('click', {} ,function(e){
        e.preventDefault();
        const $this = $(this);
        $("#edit-block-form").modal("toggle", $this);
    });
};
