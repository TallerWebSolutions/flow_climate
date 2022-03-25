import { ResponsiveLine, Serie } from "@nivo/line"

type LineGraphProps = {
  data: Serie[]
  axisLeftLegend: string
}

export const LineChart = ({ data, axisLeftLegend }: LineGraphProps) => {
  return (
    <ResponsiveLine
      data={data}
      colors={{ scheme: "pastel2" }}
      margin={{ left: 80, right: 20, top: 25, bottom: 40 }}
      axisLeft={{
        legend: axisLeftLegend,
        legendOffset: -50,
        legendPosition: "middle",
      }}
      useMesh={true}
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
}
