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


function computeTotalPayment() {
    const monthlyPayment = $('#monthly_payment');
    const hoursPerMonth = $('#hours_per_month');
    const hourValue = $('#hour_value');
    const totalMonthlyPayment = $('#total_monthly_payment');

    if (monthlyPayment.val().length === 0 && hourValue.val().length === 0 && hoursPerMonth.val().length === 0) {
        totalMonthlyPayment.val(0.00);
        return
    } else if (hourValue.val().length === 0 || hoursPerMonth.val().length === 0) {
        totalMonthlyPayment.val(monthlyPayment.val());
        return
    }

    const monthlyPaymentValue = parseFloat(monthlyPayment.val());
    const parsedHourValue = parseFloat(hourValue.val());
    const parsedHoursPerMonth = parseFloat(hoursPerMonth.val());

    totalMonthlyPayment.val((monthlyPaymentValue + (parsedHourValue * parsedHoursPerMonth)).toFixed(2));
}
