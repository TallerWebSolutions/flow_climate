import { createContext, ReactElement, useState } from "react"

import Header from "./Header"
import MessagesBox, { Message } from "./MessagesBox"

type BasicPageProps = {
  children: ReactElement | ReactElement[]
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

const BasicPage = ({ children }: BasicPageProps) => {
  const [messages, pushMessage] = useMessages()

  return (
    <MessagesContext.Provider value={{ messages, pushMessage }}>
      <Header />
      {children}
      <MessagesBox messages={messages} />
    </MessagesContext.Provider>
  )
}

export default BasicPage
