import { BarDatum, BarLegendProps, ResponsiveBar } from "@nivo/bar"
import { Box } from "@mui/material"
import { ReactElement } from "react"

import { BarData } from "./tooltips/BarChartTooltip"
import { keyValueToHistogramData } from "../../lib/charts"
import { KeyValueData } from "../../modules/charts/charts.types"

type BarChartProps = {
  data: BarDatum[] | KeyValueData
  keys: string[]
  legendLabel?: string
  indexBy: string
  axisLeftLegend?: string
  axisBottomLegend?: string
  tooltip?: (data: BarData) => ReactElement
  legendAnchor?: BarLegendProps["anchor"]
  legendDirection?: BarLegendProps["direction"]
  padding?: number
  groupMode?: "stacked" | "grouped"
  showLegends?: boolean
  height?: number
  marginBottom?: number
  marginLeft?: number
}

export const BarChart = ({
  data,
  axisLeftLegend,
  axisBottomLegend,
  indexBy,
  keys,
  legendLabel,
  legendAnchor = "top",
  legendDirection = "row",
  padding,
  groupMode = "stacked",
  showLegends = true,
  height = 420,
  marginBottom = 80,
  marginLeft = 60,
}: BarChartProps) => {
  const chartData = Array.isArray(data) ? data : keyValueToHistogramData(data)

  // eslint-disable-next-line
  console.log({ chartData })

  return (
    <Box height={height}>
      <ResponsiveBar
        legendLabel={legendLabel ? () => legendLabel : undefined}
        data={chartData}
        indexBy={indexBy}
        keys={keys}
        margin={{ top: 50, right: 50, bottom: marginBottom, left: marginLeft }}
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
        legends={
          showLegends
            ? [
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
              ]
            : undefined
        }
      />
    </Box>
  )
}
