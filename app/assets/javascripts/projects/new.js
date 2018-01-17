jQuery(function() {
    var products;
    products = $('#person_state_id').html();
    console.log(products);
    return $('#project_customer_id').change(function() {
        var customer, options;
        customer = $('#project_customer_id :selected').text();
        options = $(products).filter("optgroup[label=" + customer + "]").html();
        console.log(options);
        if (options) {
            return $('#project_product_id').html(options);
        } else {
            return $('#project_product_id').empty();
        }
    });
});