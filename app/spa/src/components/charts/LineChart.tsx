import { ResponsiveLine, Serie } from "@nivo/line"
import { Box } from "@mui/material"

export const normalizeCfdData = (data: Serie[]): Serie[] =>
  data.map((step, stepIndex) => ({
    ...step,
    data: step.data.map((dot, index) => {
      const previousY: number =
        stepIndex > 0 ? Number(data[stepIndex - 1].data[index].y) : 0
      const newY = (Number(dot?.y) || 0) - (previousY || 0)

      return {
        x: dot.x,
        y: newY,
      }
    }),
  }))

export type LineGraphProps = {
  data: Serie[]
  axisLeftLegend: string
  axisBottomLegend?: string
  props?: object
}

export const LineChart = ({
  data,
  axisLeftLegend,
  axisBottomLegend,
  props,
}: LineGraphProps) => {
  return (
    <Box height={420}>
      <ResponsiveLine
        data={data}
        colors={{ scheme: "category10" }}
        margin={{ left: 80, right: 20, top: 25, bottom: 80 }}
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
        {...props}
      />
    </Box>
  )
}
