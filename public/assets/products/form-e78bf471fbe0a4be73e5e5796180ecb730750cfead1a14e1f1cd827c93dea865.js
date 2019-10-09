$('#customer-select').on('change', function(){
    $.ajax({
        method: 'GET',
        url: `/companies/${$('#product_company_id').val()}/products/products_for_customer/${$('#customer-select').val()}`,
        dataType : 'script',
        success: function(){
            console.log("success");
        },error: function(){
            console.log("deu ruim");
        }
    })
});
