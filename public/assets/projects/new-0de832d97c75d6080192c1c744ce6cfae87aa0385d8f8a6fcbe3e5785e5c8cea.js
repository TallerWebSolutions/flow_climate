(function( $ ){
    var products;
    products = $('#project_product_id').html();
    return $('#person_country_id').change(function() {
        var customer, options;
        customer = $('#project_customer_id :selected').text();
        options = $(products).filter("optgroup[label=" + customer + "]").html();
        if (options) {
            return $('#project_product_id').html(options);
        } else {
            return $('#project_product_id').empty();
        }
    });
})( jQuery );
