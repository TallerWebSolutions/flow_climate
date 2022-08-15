import React from "react"
import { ComponentMeta, ComponentStory } from "@storybook/react"

import PieChart from "./PieChart"

export default {
  title: "Charts/PieChart",
  component: PieChart,
} as ComponentMeta<typeof PieChart>

const data = [
  {
    id: "truco",
    value: 30,
  },
  {
    id: "bisca",
    value: 20,
  },
]

export const Primary: ComponentStory<typeof PieChart> = () => (
  <PieChart data={data} />
)
