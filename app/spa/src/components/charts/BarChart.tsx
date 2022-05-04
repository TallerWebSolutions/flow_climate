import { BarDatum, BarLegendProps, ResponsiveBar } from "@nivo/bar"
import { Box, IconButton } from "@mui/material"
import { ReactElement, useRef } from "react"
import DownloadIcon from '@mui/icons-material/Download';

import { BarData } from "./tooltips/BarChartTooltip"
import { exportComponentAsPNG } from "react-component-export-image";

type BarChartProps = {
  data: BarDatum[]
  keys: string[]
  indexBy: string
  axisLeftLegend?: string
  axisBottomLegend?: string
  tooltip?: (data: BarData) => ReactElement
  legendAnchor?: BarLegendProps["anchor"]
  legendDirection?: BarLegendProps["direction"]
}

export const BarChart = ({
  data,
  axisLeftLegend,
  axisBottomLegend,
  indexBy,
  keys,
  legendAnchor = "top",
  legendDirection = "row",
}: BarChartProps) => {
  const chartRef = useRef<HTMLInputElement>(null)

  return (
    <Box position="relative">
      <IconButton onClick={() => exportComponentAsPNG(chartRef)} sx={{position: "absolute", top: "1rem", right: "1rem", zIndex: 1}}>
        <DownloadIcon />
      </IconButton>
      <Box ref={chartRef} height={380}>
        <ResponsiveBar
          data={data}
          indexBy={indexBy}
          keys={keys}
          margin={{ top: 50, right: 130, bottom: 80, left: 60 }}
          padding={0.3}
          colors={{ scheme: "category10" }}
          borderColor={{
            from: "color",
            modifiers: [["darker", 1.6]],
          }}
          axisBottom={{
            tickSize: 5,
            tickPadding: 5,
            tickRotation: -40,
            legendPosition: "middle",
            legendOffset: 40,
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
    </Box>
  )
}
