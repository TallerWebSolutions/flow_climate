import { useRef } from "react"
import {
  ResponsiveScatterPlot,
  ScatterPlotDatum,
  ScatterPlotMouseHandler,
  ScatterPlotRawSerie,
} from "@nivo/scatterplot"
import { Box, IconButton, useTheme } from "@mui/material"
import { exportComponentAsPNG } from "react-component-export-image"
import DownloadIcon from "@mui/icons-material/Download"

import { axisDataToScatter } from "../../lib/charts"
import { ChartAxisData } from "../../modules/project/project.types"

type Marker = {
  value: number
  legend: string
}

type NivoMarker = {
  axis: "y" | "x"
  value: number
  legend: string
  lineStyle: {
    stroke: string
    strokeWidth: number
  }
}

type ScatterChartProps = {
  axisLeftLegend?: string
  data: ScatterPlotRawSerie<ScatterPlotDatum>[] | ChartAxisData
  onClick?: ScatterPlotMouseHandler<ScatterPlotDatum>
  markers?: Marker[]
}

export const ScatterChart = ({
  axisLeftLegend,
  data,
  onClick,
  markers,
  ...props
}: ScatterChartProps) => {
  // eslint-disable-next-line no-console
  console.log({ data })
  const theme = useTheme()
  const chartData = Array.isArray(data)
    ? data
    : axisDataToScatter(data, "Demands")
  const chartRef = useRef<HTMLInputElement>(null)
  const chartMarkers: NivoMarker[] =
    markers?.map(({ value, legend }) => ({
      axis: "y",
      value,
      legend,
      lineStyle: { stroke: theme.palette.success.dark, strokeWidth: 2 },
    })) || []

  return (
    <Box position="relative">
      <IconButton
        onClick={() => exportComponentAsPNG(chartRef)}
        sx={{ position: "absolute", top: "1rem", right: "1rem", zIndex: 1 }}
      >
        <DownloadIcon />
      </IconButton>
      <Box ref={chartRef} height={380}>
        <ResponsiveScatterPlot
          data={chartData}
          margin={{ left: 65, right: 40, top: 25, bottom: 40 }}
          xScale={{ type: "linear", min: "auto", max: "auto" }}
          yScale={{ type: "linear", min: "auto", max: "auto" }}
          colors={{ scheme: "category10" }}
          axisTop={null}
          axisRight={null}
          blendMode="multiply"
          onClick={onClick}
          nodeSize={6}
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
          useMesh={true}
          legends={[
            {
              anchor: "top",
              direction: "row",
              toggleSerie: true,
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
          markers={chartMarkers}
          {...props}
        />
      </Box>
    </Box>
  )
}
