import { createContext, ReactElement, useState } from "react"
import { Container, Box, Typography } from "@mui/material"
import Header from "./Header"
import MessagesBox, { Message } from "./MessagesBox"
import Breadcrumbs, { BreadcrumbsLink } from "./Breadcrumbs"
import { Company } from "../modules/company/company.types"

export type BasicPageProps = {
  title: string
  breadcrumbsLinks: BreadcrumbsLink[]
  children?: ReactElement | ReactElement[]
  company?: Company
}

export const MessagesContext = createContext<{
  messages: Message[]
  pushMessage: (message: Message) => void
}>({
  messages: [],
  pushMessage: () => {},
})

const useMessages = (): [Message[], (message: Message) => void] => {
  const [messages, setMessages] = useState<Message[]>([])

  const pushMessage = (message: Message) => {
    setMessages((messages) => [...messages, message])
  }

  return [messages, pushMessage]
}

const BasicPage = ({
  children,
  title,
  breadcrumbsLinks,
  company,
}: BasicPageProps) => {
  const [messages, pushMessage] = useMessages()

  return (
    <MessagesContext.Provider value={{ messages, pushMessage }}>
      <Header company={company} />
      <Container maxWidth="xl">
        <Breadcrumbs links={breadcrumbsLinks} />
        <Typography component="h1" variant="h4" mb={3}>
          {title}
        </Typography>
        {children}
        <MessagesBox messages={messages} />
      </Container>
    </MessagesContext.Provider>
  )
}

export default BasicPage
