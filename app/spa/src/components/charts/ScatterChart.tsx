import {
  ResponsiveScatterPlot,
  ScatterPlotDatum,
  ScatterPlotRawSerie,
} from "@nivo/scatterplot"

type ScatterChartProps = {
  axisLeftLegend?: string
  data: ScatterPlotRawSerie<ScatterPlotDatum>[]
}

export const ScatterChart = ({ axisLeftLegend, data }: ScatterChartProps) => (
  <ResponsiveScatterPlot
    data={data}
    margin={{ left: 65, right: 40, top: 25, bottom: 40 }}
    xScale={{ type: "linear", min: 0, max: "auto" }}
    yScale={{ type: "linear", min: 0, max: "auto" }}
    blendMode="multiply"
    axisTop={null}
    axisRight={null}
    axisBottom={{
      tickSize: 5,
      tickPadding: 5,
      tickRotation: 0,
    }}
    axisLeft={{
      tickSize: 5,
      tickPadding: 5,
      tickRotation: 0,
      legend: axisLeftLegend,
      legendPosition: "middle",
      legendOffset: -45,
    }}
    legends={[
      {
        anchor: "top",
        direction: "row",
        justify: false,
        translateX: 0,
        translateY: -25,
        itemsSpacing: 0,
        itemDirection: "left-to-right",
        itemWidth: 125,
        itemHeight: 20,
        itemOpacity: 0.75,
        symbolSize: 12,
        symbolShape: "circle",
        symbolBorderColor: "rgba(0, 0, 0, .5)",
        effects: [
          {
            on: "hover",
            style: {
              itemBackground: "rgba(0, 0, 0, .03)",
              itemOpacity: 1,
            },
          },
        ],
      },
    ]}
  />
)
