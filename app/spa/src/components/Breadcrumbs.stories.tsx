import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import Breadcrumbs from "./Breadcrumbs"

export default {
  title: "Breadcrumbs",
  component: Breadcrumbs,
} as ComponentMeta<typeof Breadcrumbs>

const links = [
  { name: "Root", link: "/" },
  { name: "Special", link: "/" },
]

export const Primary: ComponentStory<typeof Breadcrumbs> = () => (
  <Breadcrumbs links={links} currentPageName="Today" />
)
