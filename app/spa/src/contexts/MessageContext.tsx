import { createContext } from "react"
import { Message } from "../components/MessagesBox"

export const MessagesContext = createContext<{
  messages: Message[]
  pushMessage: (message: Message) => void
}>({
  messages: [],
  pushMessage: () => {},
})
