$(document).on('click', '.new-jira-config-button', {} ,function(e){
    e.preventDefault();
    const $this = $(this);
    $('#new-project-jira-config-form').modal('toggle', $this);
});
