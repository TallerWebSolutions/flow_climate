import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import {BarChart} from "./BarChart"

export default {
  title: "Charts/BarChart",
  component: BarChart,
} as ComponentMeta<typeof BarChart>

const data = [{
  name: "Fool Ano",
  "Demands Count": 10,
  "Hours Count": 160,
  "Months Count": 9,
},{
  name: "Bell Trano",
  "Demands Count": 20,
  "Hours Count": 120,
  "Months Count": 7,
},{
  name: "See Crano",
  "Demands Count": 15,
  "Hours Count": 360,
  "Months Count": 19,
}]

const props = {
  data,
  indexBy: "name",
  keys: ["Demands Count", "Hours Count", "Months Count"],
  axisBottomLegend: "People",
  axisLeftLegend: "Demands"
}

export const Primary: ComponentStory<typeof BarChart> = () => (
  <BarChart {...props} />
)

export const CustomLegends: ComponentStory<typeof BarChart> = () => (
  <BarChart {...props} legendAnchor="top-left" legendDirection="column" />
)