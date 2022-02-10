import { forwardRef, useRef } from "react"
import { ResponsivePie } from "@nivo/pie"
import { Box } from "@mui/material"
import { exportComponentAsPNG } from "react-component-export-image"

import BasicPage from "../components/BasicPage"

const data = [
  {
    id: "javascript",
    label: "javascript",
    value: 284,
    color: "hsl(114, 70%, 50%)",
  },
  {
    id: "stylus",
    label: "stylus",
    value: 262,
    color: "hsl(167, 70%, 50%)",
  },
  {
    id: "python",
    label: "python",
    value: 184,
    color: "hsl(145, 70%, 50%)",
  },
  {
    id: "php",
    label: "php",
    value: 529,
    color: "hsl(242, 70%, 50%)",
  },
  {
    id: "elixir",
    label: "elixir",
    value: 346,
    color: "hsl(37, 70%, 50%)",
  },
]

const Chart = forwardRef((_, ref) => (
  <Box ref={ref} height={500}>
    <ResponsivePie
      data={data}
      margin={{ top: 40, right: 80, bottom: 80, left: 80 }}
      innerRadius={0.5}
      padAngle={0.7}
      cornerRadius={3}
      activeOuterRadiusOffset={8}
      borderWidth={1}
      borderColor={{
        from: "color",
        modifiers: [["darker", 0.2]],
      }}
      arcLinkLabelsSkipAngle={10}
      arcLinkLabelsTextColor="#333333"
      arcLinkLabelsThickness={2}
      arcLinkLabelsColor={{ from: "color" }}
      arcLabelsSkipAngle={10}
      arcLabelsTextColor={{
        from: "color",
        modifiers: [["darker", 2]],
      }}
      defs={[
        {
          id: "dots",
          type: "patternDots",
          background: "inherit",
          color: "rgba(255, 255, 255, 0.3)",
          size: 4,
          padding: 1,
          stagger: true,
        },
        {
          id: "lines",
          type: "patternLines",
          background: "inherit",
          color: "rgba(255, 255, 255, 0.3)",
          rotation: -45,
          lineWidth: 6,
          spacing: 10,
        },
      ]}
      fill={[
        {
          match: {
            id: "ruby",
          },
          id: "dots",
        },
        {
          match: {
            id: "c",
          },
          id: "dots",
        },
        {
          match: {
            id: "go",
          },
          id: "dots",
        },
        {
          match: {
            id: "python",
          },
          id: "dots",
        },
        {
          match: {
            id: "scala",
          },
          id: "lines",
        },
        {
          match: {
            id: "lisp",
          },
          id: "lines",
        },
        {
          match: {
            id: "elixir",
          },
          id: "lines",
        },
        {
          match: {
            id: "javascript",
          },
          id: "lines",
        },
      ]}
      legends={[
        {
          anchor: "bottom",
          direction: "row",
          justify: false,
          translateX: 0,
          translateY: 56,
          itemsSpacing: 0,
          itemWidth: 100,
          itemHeight: 18,
          itemTextColor: "#999",
          itemDirection: "left-to-right",
          itemOpacity: 1,
          symbolSize: 18,
          symbolShape: "circle",
          effects: [
            {
              on: "hover",
              style: {
                itemTextColor: "#000",
              },
            },
          ],
        },
      ]}
    />
  </Box>
))

const StatusReport = () => {
  const ref: any = useRef()

  return (
    <BasicPage>
      <button onClick={() => exportComponentAsPNG(ref)}>Exportar</button>
      <Chart ref={ref} />
    </BasicPage>
  )
}

export default StatusReport
