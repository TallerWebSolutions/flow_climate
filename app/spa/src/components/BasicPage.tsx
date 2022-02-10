import { createContext, ReactElement, useState } from "react"
import { Container, Typography } from "@mui/material"

import Header from "./Header"
import MessagesBox, { Message } from "./MessagesBox"

type BasicPageProps = {
  children?: ReactElement | ReactElement[]
  title: string
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

const BasicPage = ({ children, title }: BasicPageProps) => {
  const [messages, pushMessage] = useMessages()

  return (
    <MessagesContext.Provider value={{ messages, pushMessage }}>
      <Header />
      <Container maxWidth="xl">
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
