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
  legendTranslateX?: number
  legendTranslateY?: number
  legendItemWidth?: number
  legendItemHeight?: number
  height?: number
  marginTop?: number
  marginBottom?: number
  marginLeft?: number
  marginRight?: number
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
  legendTranslateX = 0,
  legendTranslateY = -25,
  legendItemWidth = 125,
  legendItemHeight = 20,
  height = 420,
  marginTop = 50,
  marginBottom = 80,
  marginLeft = 60,
  marginRight = 50,
}: BarChartProps) => {
  const chartData = Array.isArray(data) ? data : keyValueToHistogramData(data)

  return (
    <Box height={height}>
      <ResponsiveBar
        legendLabel={legendLabel ? () => legendLabel : undefined}
        data={chartData}
        indexBy={indexBy}
        keys={keys}
        margin={{
          top: marginTop,
          right: marginRight,
          bottom: marginBottom,
          left: marginLeft,
        }}
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
                  translateX: legendTranslateX,
                  translateY: legendTranslateY,
                  itemsSpacing: 0,
                  itemDirection: "left-to-right",
                  itemWidth: legendItemWidth,
                  itemHeight: legendItemHeight,
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
