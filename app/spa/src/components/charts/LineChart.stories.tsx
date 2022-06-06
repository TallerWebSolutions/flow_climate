// @ts-ignore
import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import ChartLineBox from "./ChartLineBox"
import { normalizeCfdData } from "./LineChart"

export default {
  title: "Charts/ChartLineBox",
  component: ChartLineBox,
} as ComponentMeta<typeof ChartLineBox>

const data = [
  {
    id: "Done",
    data: [
      {
        x: 0,
        y: 10,
      },
      {
        x: 1,
        y: 12,
      },
      {
        x: 2,
        y: 16,
      },
    ],
  },
  {
    id: "Doing",
    data: [
      {
        x: 0,
        y: 11,
      },
      {
        x: 1,
        y: 13,
      },
      {
        x: 2,
        y: 17,
      },
    ],
  },
  {
    id: "Ready",
    data: [
      {
        x: 0,
        y: 12,
      },
      {
        x: 1,
        y: 15,
      },
      {
        x: 2,
        y: 18,
      },
    ],
  },
]

export const CFD: ComponentStory<typeof ChartLineBox> = () => (
  <ChartLineBox
    title="Cumulative flow data"
    data={normalizeCfdData(data)}
    axisLeftLegend="Demands"
    props={{
      yScale: {
        type: "linear",
        stacked: true,
      },
      areaOpacity: 1,
      enableArea: true,
      enableSlices: "x",
      margin: { left: 80, right: 20, top: 25, bottom: 65 },
      axisBottom: {
        tickSize: 5,
        tickPadding: 5,
        legendPosition: "middle",
        legendOffset: 60,
        tickRotation: -40,
      },
    }}
  />
)
