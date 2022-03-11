$('#tasks_project').on('change', function() {
    $('#tasks_team').val('')
})

$('#tasks_team').on('change', function() {
    $('#tasks_project').val('')
})
