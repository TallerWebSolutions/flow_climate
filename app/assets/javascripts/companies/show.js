hideAllComponents($('.nav-item'));

const stampsDiv = $('#nav-item-stamps');
stampsDiv.addClass('active');
$('#stamps').show();

$("#general-loader").hide();

buildFinancesHighcharts();
