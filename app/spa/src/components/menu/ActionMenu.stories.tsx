import { ComponentStory, ComponentMeta } from "@storybook/react"

import ActionMenu from "./ActionMenu"

export default {
  title: "ActionMenu",
  component: ActionMenu,
} as ComponentMeta<typeof ActionMenu>

const items = [
  {
    name: "Dashboard",
    onClick: () => alert("Dashboard"),
  },
  {
    name: "Projects",
    href: "#",
  },
]

export const Primary: ComponentStory<typeof ActionMenu> = () => (
  <ActionMenu items={items} />
)
