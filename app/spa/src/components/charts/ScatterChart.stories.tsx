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

const withMarkersData = [
  {
    id: "Demands Scatter",
    data: [
      {
        x: "Demand-1",
        y: 10,
      },
      {
        x: "Demand-2",
        y: 13,
      },
      {
        x: "Demand-3",
        y: 8,
      },
      {
        x: "Demand-4",
        y: 1,
      },
      {
        x: "Demand-5",
        y: 9,
      },
      {
        x: "Demand-6",
        y: 6,
      },
    ],
  },
]

const markers = [
  { value: withMarkersData[0].data[4].y, legend: "test" },
  { value: withMarkersData[0].data[5].y, legend: "another test" },
]

export const WithMarkers: ComponentStory<typeof ScatterChart> = () => (
  <ScatterChart markers={markers} data={withMarkersData} />
)

export const WithClick: ComponentStory<typeof ScatterChart> = () => (
  <ScatterChart
    markers={markers}
    data={withMarkersData}
    onClick={(props) => {
      alert(`You just clicked on item ${props.data.x}`)
    }}
  />
)

const bigData = [
  {
    id: "Demands Scatter",
    data: [
      {
        x: "Demand-1",
        y: 10,
      },
      {
        x: "Demand-2",
        y: 13,
      },
      {
        x: "Demand-3",
        y: 8,
      },
      {
        x: "Demand-4",
        y: 1,
      },
      {
        x: "Demand-5",
        y: 9,
      },
      {
        x: "Demand-6",
        y: 6,
      },
      {
        x: "Demand-7",
        y: 6,
      },
      {
        x: "Demand-8",
        y: 6,
      },
      {
        x: "Demand-9",
        y: 6,
      },
      {
        x: "Demand-10",
        y: 6,
      },
      {
        x: "Demand-11",
        y: 10,
      },
      {
        x: "Demand-12",
        y: 6,
      },
      {
        x: "Demand-13",
        y: 8,
      },
      {
        x: "Demand-14",
        y: 6,
      },
      {
        x: "Demand-15",
        y: 3,
      },
      {
        x: "Demand-16",
        y: 6,
      },
      {
        x: "Demand-17",
        y: 6,
      },
      {
        x: "Demand-18",
        y: 6,
      },
      {
        x: "Demand-19",
        y: 9,
      },
      {
        x: "Demand-20",
        y: 6,
      },
      {
        x: "Demand-21",
        y: 6,
      },
      {
        x: "Demand-22",
        y: 4,
      },
      {
        x: "Demand-23",
        y: 6,
      },
      {
        x: "Demand-24",
        y: 6,
      },
      {
        x: "Demand-25",
        y: 6,
      },
      {
        x: "Demand-26",
        y: 6,
      },
      {
        x: "Demand-27",
        y: 2,
      },
      {
        x: "Demand-28",
        y: 6,
      },
      {
        x: "Demand-29",
        y: 6,
      },
      {
        x: "Demand-30",
        y: 11,
      },
      {
        x: "Demand-31",
        y: 6,
      },
      {
        x: "Demand-32",
        y: 3,
      },
      {
        x: "Demand-33",
        y: 6,
      },
    ],
  },
]

export const WithTooMuchData: ComponentStory<typeof ScatterChart> = () => (
  <ScatterChart data={bigData} />
)
