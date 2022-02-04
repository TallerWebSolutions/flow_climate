function buildScatterChart(scatterDiv) {
  new Highcharts.Chart({
    chart: {
      type: "scatter",
      zoomType: "xy",
      renderTo: scatterDiv.attr("id"),
    },
    title: {
      text: scatterDiv.data("title"),
      x: -20, //center
    },
    subtitle: {
      text: "Source: Flow Climate",
    },
    xAxis: {
      categories: scatterDiv.data("xcategories"),
      title: { text: scatterDiv.data("xtitle") },
    },
    yAxis: {
      title: {
        text: scatterDiv.data("tooltipsuffix"),
      },
      plotLines: [
        {
          value: scatterDiv.data("percentile95"),
          color: "green",
          dashStyle: "shortdash",
          width: 2,
          label: {
            style: {
              color: "green",
            },
            text: `percentile 95% (${parseFloat(
                scatterDiv.data("percentile95")
            ).toFixed(2)} ${scatterDiv.data("tooltipsuffix")})`,
          },
        },
        {
          value: scatterDiv.data("percentile80"),
          color: "#DAA520",
          dashStyle: "shortdash",
          width: 2,
          label: {
            style: {
              color: "#DAA520",
            },
            text: `percentile 80% (${parseFloat(
                scatterDiv.data("percentile80")
            ).toFixed(2)} ${scatterDiv.data("tooltipsuffix")})`,
          },
        },
        {
          value: scatterDiv.data("percentile65"),
          color: "red",
          dashStyle: "shortdash",
          width: 2,
          label: {
            style: {
              color: "red",
            },
            text: `percentile 65% (${parseFloat(
                scatterDiv.data("percentile65")
            ).toFixed(2)} ${scatterDiv.data("tooltipsuffix")})`,
          },
        },
      ],
    },
    tooltip: {
      formatter: function () {
        return `${this.x}: ${this.y.toFixed(2)} ${scatterDiv.data("tooltipsuffix")}`;
      },
    },
    legend: {
      type: 'line',
      align: 'center',
      verticalAlign: 'top',
      x: 0,
      y: 0
    },
    plotOptions: {
      scatter: {
        marker: {
          radius: 2,
          states: {
            hover: {
              enabled: true,
              lineColor: "rgb(100,100,100)",
            },
          },
        },
        states: {
          hover: {
            marker: {
              enabled: false,
            },
          },
        },
      },
      series: {
        point: {
          events: {
            click: function () {
              if (this.url) {
                window.open(this.url);
              }
            }
          }
        }
      },
    },

    series: scatterDiv.data("series"),
  });
}
