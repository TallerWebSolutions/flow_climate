$('#customer-select').on('change', function(){
    $.ajax({
        method: 'GET',
        url: `/companies/${$('#project_company_id').val()}/projects/product_options_for_customer/${$('#customer-select').val()}`,
        dataType : 'script',
        success: function(){
            console.log("success");
        },error: function(){
            console.log("deu ruim");
        }
    })
});
