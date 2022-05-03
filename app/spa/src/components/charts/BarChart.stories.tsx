import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import {BarChart} from "./BarChart"

export default {
  title: "Charts/BarChart",
  component: BarChart,
} as ComponentMeta<typeof BarChart>

const data = [{
  name: "Fool Ano",
  "Demands Count": 10
},{
  name: "Bell Trano",
  "Demands Count": 20
},{
  name: "See Crano",
  "Demands Count": 15
}]

const props = {
  data,
  indexBy: "name",
  keys: ["Demands Count"],
  axisBottomLegend: "People",
  axisLeftLegend: "Demands"
}

export const Primary: ComponentStory<typeof BarChart> = () => (
  <BarChart {...props} />
)
