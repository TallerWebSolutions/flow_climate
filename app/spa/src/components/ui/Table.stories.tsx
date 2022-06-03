import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import Table from "./Table"

export default {
  title: "Table",
  component: Table,
} as ComponentMeta<typeof Table>

const rows = [
  ["Shirt", "19,99", 9],
  ["Pants", "29,99", 19],
  ["Shorts", "24,99", 11],
]

export const Primary: ComponentStory<typeof Table> = () => (
  <Table
    title="Clothes"
    headerCells={["Name", "Price", "Quantity"]}
    rows={rows}
    footerCells={["Total", "", "39"]}
  />
)

export const WithPagination: ComponentStory<typeof Table> = () => (
  <Table
    title="Clothes"
    headerCells={["Name", "Price", "Quantity"]}
    rows={rows}
    footerCells={["Total", "", "39"]}
    pagination={{
      count: 100,
      rowsPerPage: 10,
      page: 1,
      onPageChange: () => alert("To be done"),
    }}
  />
)
