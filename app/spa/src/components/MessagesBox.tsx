import { useState } from "react"
import { Alert, Collapse, Stack } from "@mui/material"

export type Message = {
  severity: string
  text: string
}

const MessageBox = ({ message }: { message: Message }) => {
  const [open, setOpen] = useState(true)

  return (
    <Collapse in={open}>
      <Alert data-testid="message-box" onClose={() => setOpen(() => false)}>
        {message.text}
      </Alert>
    </Collapse>
  )
}

const MessagesBox = ({ messages }: { messages: Message[] }) => (
  <Stack sx={{ position: "fixed", marginBottom: 2, bottom: 0 }} spacing={2}>
    {messages.map((message, index) => (
      <MessageBox key={index + "--" + message.text} message={message} />
    ))}
  </Stack>
)

export default MessagesBox