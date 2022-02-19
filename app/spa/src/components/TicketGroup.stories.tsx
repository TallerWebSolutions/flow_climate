import { ComponentStory, ComponentMeta } from "@storybook/react"

import TicketGroup from "./TicketGroup"

export default {
  title: "Ticket Group",
  component: TicketGroup,
} as ComponentMeta<typeof TicketGroup>

const data = [
  {
    title: "Custo",
    value: "R$ 178.000,00",
  },
  {
    title: "Prazo",
    value: "10/12/2022",
  },
  {
    title: "Esforço",
    value: "398 horas",
  },
  {
    title: "Risco",
    value: "39%",
  },
]

export const Primary: ComponentStory<typeof TicketGroup> = () => (
  <TicketGroup title="Dados atuais" data={data} />
)
