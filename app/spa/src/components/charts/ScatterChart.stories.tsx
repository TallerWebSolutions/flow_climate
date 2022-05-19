// @ts-ignore
import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import { ScatterChart } from "./ScatterChart"

export default {
  title: "Charts/ScatterChart",
  component: ScatterChart,
} as ComponentMeta<typeof ScatterChart>

const data = {
  xAxis: [
    "COB-7",
    "NXCF-129",
    "UNICEF-3",
    "NXCF-145",
    "NXCF-173",
    "NXCF-153",
    "NXCF-171",
    "NXCF-197",
    "NXCF-184",
    "NXCF-196",
    "NFAQ-2",
    "UNICEF-22",
  ],
  yAxis: [
    1236207.821, 435295.31, 1385342.243, 362509.257, 83641.125, 808098.289,
    191610.467, 83602.277, 1283692.171, 317521.483, 769342.66, 345329.085,
  ],
}

const props = { data }

export const Primary: ComponentStory<typeof ScatterChart> = () => (
  <ScatterChart {...props} />
)
