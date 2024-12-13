import { ResponsiveLine, Serie } from "@nivo/line"
import { LegendAnchor, LegendDirection } from "@nivo/legends"
import { Box } from "@mui/material"

export const normalizeCfdData = (data: Serie[]): Serie[] =>
  data.map((step, stepIndex) => ({
    ...step,
    data: step.data?.map((dot, index) => {
      const previousY: number =
        stepIndex > 0 ? Number(data[stepIndex - 1].data?.[index].y) : 0
      const newY = (Number(dot?.y) || 0) - (previousY || 0)

      return {
        x: dot.x,
        y: newY,
      }
    }),
  }))

export type LineChartProps = {
  data: Serie[]
  axisLeftLegend: string
  axisBottomLegend?: string
  props?: object
  marginTop?: number
  marginBottom?: number
  marginLeft?: number
  marginRight?: number
  legendAnchor?: LegendAnchor
  legendDirection?: LegendDirection
  legendTranslateX?: number
  legendTranslateY?: number
  legendItemWidth?: number
  legendItemHeight?: number
}

export const LineChart = ({
  data,
  axisLeftLegend,
  axisBottomLegend,
  props,
  marginTop = 25,
  marginBottom = 80,
  marginLeft = 80,
  marginRight = 20,
  legendAnchor = "top",
  legendDirection = "row",
  legendTranslateX = 0,
  legendTranslateY = -25,
  legendItemWidth = 125,
  legendItemHeight = 20,
}: LineChartProps) => {
  return (
    <Box height={420}>
      <ResponsiveLine
        data={data}
        colors={{ scheme: "category10" }}
        margin={{
          left: marginLeft,
          right: marginRight,
          top: marginTop,
          bottom: marginBottom,
        }}
        yScale={{ type: "linear", min: "auto", max: "auto" }}
        axisLeft={{
          legend: axisLeftLegend,
          legendOffset: -50,
          legendPosition: "middle",
        }}
        axisBottom={{
          tickSize: 5,
          tickPadding: 5,
          tickRotation: -40,
          legendPosition: "middle",
          legendOffset: 60,
          legend: axisBottomLegend,
        }}
        useMesh={true}
        legends={[
          {
            toggleSerie: true,
            anchor: legendAnchor,
            direction: legendDirection,
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
        ]}
        {...props}
      />
    </Box>
  )
}
