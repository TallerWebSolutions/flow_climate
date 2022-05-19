// @ts-ignore
import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import { BarChart } from "./BarChart"

export default {
  title: "Charts/BarChart",
  component: BarChart,
} as ComponentMeta<typeof BarChart>

const data = [
  {
    name: "Fool Ano",
    "Demands Count": 10,
    "Hours Count": 160,
    "Months Count": 9,
  },
  {
    name: "Bell Trano",
    "Demands Count": 20,
    "Hours Count": 120,
    "Months Count": 7,
  },
  {
    name: "See Crano",
    "Demands Count": 15,
    "Hours Count": 360,
    "Months Count": 19,
  },
]

const props = {
  data,
  indexBy: "name",
  keys: ["Demands Count", "Hours Count", "Months Count"],
  axisBottomLegend: "People",
  axisLeftLegend: "Demands",
}

export const Primary: ComponentStory<typeof BarChart> = () => (
  <BarChart {...props} />
)

export const CustomLegends: ComponentStory<typeof BarChart> = () => (
  <BarChart {...props} legendAnchor="top-left" legendDirection="column" />
)

export const TooManyLegends: ComponentStory<typeof BarChart> = () => (
  <BarChart
    {...props}
    keys={[
      "Demands Count",
      "Hours Count XPTO Bla",
      "Months Count Sbbrubles",
      "Products Count",
      "Xpto Count",
      "Truco Count",
    ]}
  />
)

const histogramData = {
  keys: [
    303314.1821111111, 904267.3883333333, 1505220.5945555556,
    2106173.8007777776, 2707127.007, 3308080.2132222224, 3909033.4194444446,
    4509986.625666667, 5110939.831888889, 5711893.038111111, 6312846.244333333,
    6913799.4505555555, 7514752.656777778, 8115705.863, 8716659.069222223,
    9317612.275444444, 9918565.481666667, 10519518.687888889,
  ],
  values: [130, 86, 52, 26, 6, 8, 4, 2, 5, 0, 0, 0, 0, 0, 0, 0, 0, 1],
}

export const Histogram: ComponentStory<typeof BarChart> = () => (
  <BarChart indexBy="key" data={histogramData} keys={["value"]} padding={0} />
)
