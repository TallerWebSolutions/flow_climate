$('#tasks_initiative').on('change', function() {
    $('#tasks_team').val('')
    $('#tasks_project').val('')
})

$('#tasks_project').on('change', function() {
    $('#tasks_team').val('')
    $('#tasks_initiative').val('')
})

$('#tasks_team').on('change', function() {
    $('#tasks_project').val('')
    $('#tasks_initiative').val('')
});
