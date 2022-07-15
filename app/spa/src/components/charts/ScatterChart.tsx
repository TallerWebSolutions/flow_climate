import {
  ResponsiveScatterPlot,
  ScatterPlotDatum,
  ScatterPlotMouseHandler,
  ScatterPlotRawSerie,
} from "@nivo/scatterplot"
import { Box, Paper, useTheme } from "@mui/material"

import { axisDataToScatter } from "../../lib/charts"
import { ChartAxisData } from "../../modules/project/project.types"
import { useTranslation } from "react-i18next"

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

const reduceTicks = (ticks: (string | number | Date)[]) => {
  if (ticks.length <= 20) return ticks
  const factor = Math.ceil(ticks.length / 20)
  return ticks.filter((_, index) => index % factor === 0)
}

export const ScatterChart = ({
  axisLeftLegend,
  data,
  onClick,
  markers,
  ...props
}: ScatterChartProps) => {
  const theme = useTheme()
  const { t } = useTranslation("common")
  const chartData = Array.isArray(data)
    ? data
    : axisDataToScatter(data, "Demands")
  const bottomAxisTicks = chartData[0].data.map((item) => item.x)
  const chartMarkers: NivoMarker[] =
    markers?.map(({ value, legend }) => ({
      axis: "y",
      value,
      legend,
      lineStyle: { stroke: theme.palette.success.dark, strokeWidth: 2 },
    })) || []

  return (
    <Box height={380} style={{ fontSize: 12 }}>
      <ResponsiveScatterPlot
        data={chartData}
        margin={{ left: 65, right: 40, top: 25, bottom: 40 }}
        xScale={{ type: "point" }}
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
          tickRotation: -30,
          tickValues: reduceTicks(bottomAxisTicks),
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
        tooltip={({ node }) => (
          <Paper elevation={3} sx={{ padding: 1 }}>
            {node.data.x}
            <br />
            Lead time: {node.data.y} {t("days")}
          </Paper>
        )}
        enableGridX={false}
        enableGridY={false}
        {...props}
      />
    </Box>
  )
}
