import { BarDatum, BarLegendProps, ResponsiveBar } from "@nivo/bar"
import { Box } from "@mui/material"
import { ReactElement } from "react"

import { BarData } from "./tooltips/BarChartTooltip"
import { KeyValueData } from "../../modules/project/project.types"
import { keyValueToHistogramData } from "../../lib/charts"

type BarChartProps = {
  data: BarDatum[] | KeyValueData
  keys: string[]
  indexBy: string
  axisLeftLegend?: string
  axisBottomLegend?: string
  tooltip?: (data: BarData) => ReactElement
  legendAnchor?: BarLegendProps["anchor"]
  legendDirection?: BarLegendProps["direction"]
  padding?: number
  groupMode?: "stacked" | "grouped"
}

export const BarChart = ({
  data,
  axisLeftLegend,
  axisBottomLegend,
  indexBy,
  keys,
  legendAnchor = "top",
  legendDirection = "row",
  padding,
  groupMode = "stacked",
}: BarChartProps) => {
  const chartData = Array.isArray(data) ? data : keyValueToHistogramData(data)

  return (
    <Box height={420}>
      <ResponsiveBar
        data={chartData}
        indexBy={indexBy}
        keys={keys}
        margin={{ top: 50, right: 50, bottom: 80, left: 60 }}
        groupMode={groupMode}
        padding={Number.isNaN(padding) ? 0.3 : padding}
        colors={{ scheme: "paired" }}
        borderColor={{
          from: "color",
          modifiers: [["darker", 1.6]],
        }}
        axisBottom={{
          tickSize: 5,
          tickPadding: 5,
          tickRotation: -40,
          legendPosition: "middle",
          legendOffset: 65,
          legend: axisBottomLegend,
        }}
        axisLeft={{
          tickSize: 5,
          tickPadding: 5,
          tickRotation: 0,
          legend: axisLeftLegend,
          legendPosition: "middle",
          legendOffset: -40,
        }}
        labelSkipWidth={12}
        labelSkipHeight={12}
        labelTextColor={{
          from: "color",
          modifiers: [["darker", 1.6]],
        }}
        legends={[
          {
            dataFrom: "keys",
            anchor: legendAnchor,
            direction: legendDirection,
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
      />
    </Box>
  )
}
