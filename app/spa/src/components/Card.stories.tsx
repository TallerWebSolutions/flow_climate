import React from "react"

import { ComponentStory, ComponentMeta } from "@storybook/react"

import Card, { CardType } from "./Card"

export default {
  title: "Card",
  component: Card,
} as ComponentMeta<typeof Card>

export const Primary: ComponentStory<typeof Card> = () => (
  <Card
    title="Card Component"
    subtitle="The best card in the world"
    type={CardType.PRIMARY}
  />
)

export const Warning: ComponentStory<typeof Card> = () => (
  <Card
    title="Card Component"
    subtitle="The best card in the world"
    type={CardType.WARNING}
  />
)

export const Success: ComponentStory<typeof Card> = () => (
  <Card
    title="Card Component"
    subtitle="The best card in the world"
    type={CardType.SUCCESS}
  />
)
