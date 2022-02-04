import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import Card, { CardType } from "./Card"

export default {
  title: "Card",
  component: Card,
} as ComponentMeta<typeof Card>

export const Primary: ComponentStory<typeof Card> = () => (
  <Card title="Card Component" subtitle="The best card in the world" />
)
export const Alert: ComponentStory<typeof Card> = () => (
  <Card
    title="Card Component"
    subtitle="The best card in the world"
    type={CardType.alert}
  />
)
