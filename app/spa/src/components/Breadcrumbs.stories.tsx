import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import Breadcrumbs from "./Breadcrumbs"

export default {
  title: "Breadcrumbs",
  component: Breadcrumbs,
} as ComponentMeta<typeof Breadcrumbs>

const links = [
  { name: "Root", url: "/" },
  { name: "Special", url: "/" },
  { name: "Today" },
]

export const Primary: ComponentStory<typeof Breadcrumbs> = () => (
  <Breadcrumbs links={links} />
)
