$(document).ready(function() {
    computeTotalPayment();
});

$('#monthly_payment').on('keyup', function(){
    computeTotalPayment();
});

$('#hours_per_month').on('keyup', function(){
    computeTotalPayment();
});

$('#hour_value').on('keyup', function(){
    computeTotalPayment();
});


var computeTotalPayment = function() {
    var monthlyPayment = $('#monthly_payment');
    var hoursPerMonth = $('#hours_per_month');
    var hourValue = $('#hour_value');
    var totalMonthlyPayment = $('#total_monthly_payment');

    if (monthlyPayment.val().length === 0 && hourValue.val().length === 0 && hoursPerMonth.val().length === 0) {
        totalMonthlyPayment.val(0.00);
        return
    } else if (hourValue.val().length === 0 || hoursPerMonth.val().length === 0) {
        totalMonthlyPayment.val(monthlyPayment.val());
        return
    }

    var monthlyPaymentValue = parseFloat(monthlyPayment.val());
    var hour_value = parseFloat(hourValue.val());
    var hours_per_month = parseFloat(hoursPerMonth.val());

    totalMonthlyPayment.val((monthlyPaymentValue + (hour_value * hours_per_month)).toFixed(2));
};