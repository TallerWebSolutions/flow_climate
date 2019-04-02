$('#flow_impact_project_id').on('change', function(){
    $.ajax({
        method: 'GET',
        url: `/companies/${$('#company_id').val()}/flow_impacts/demands_to_project/${$('#flow_impact_project_id').val()}`,
        dataType : 'script',
        success: function(){
            console.log("success");
        },error: function(){
            console.log("deu ruim");
        }
    })
});
