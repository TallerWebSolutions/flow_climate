$(function () {
  var burnupDiv = $('#burnup');

  burnupDiv.highcharts({
    title: {
      text: 'Burn-up',
      x: -20 //center
    },
    subtitle: {
      text: 'Source: Flow Control'
    },
    xAxis: {
      categories: burnupDiv.data('weeks'),
      title: { text: burnupDiv.data('xtitle') }
    },
    yAxis: {
      title: {
        text: burnupDiv.data('ytitle')
      },
      plotLines: [{
        value: 0,
        width: 1,
        color: '#808080'
      }]
    },
    tooltip: {
      valueSuffix: burnupDiv.data('tooltipsufix')
    },
    legend: {
      layout: 'vertical',
      align: 'right',
      verticalAlign: 'middle',
      borderWidth: 0
    },
    series: [{
      name: 'Escopo',
      data: burnupDiv.data('scope')
    }, {
      name: 'Ideal',
      data: burnupDiv.data('ideal')
    }, {
      name: 'Atual',
      data: burnupDiv.data('current')
    }]
  });
});
