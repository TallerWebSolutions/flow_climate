import { useState } from "react"
import { Alert, Collapse, Stack } from "@mui/material"

export type Message = {
  severity?: "info" | "error" | "success" | "warning" | undefined
  text: string
}

const MessageBox = ({ message }: { message: Message }) => {
  const [open, setOpen] = useState(true)

  return (
    <Collapse in={open}>
      <Alert
        color={message.severity}
        data-testid="message-box"
        onClose={() => setOpen(() => false)}
      >
        {message.text}
      </Alert>
    </Collapse>
  )
}

const MessagesBox = ({ messages }: { messages: Message[] }) => (
  <Stack sx={{ position: "fixed", marginBottom: 2, bottom: 0 }} spacing={2}>
    {messages.map((message, index) => (
      <MessageBox key={index + "--" + message.severity} message={message} />
    ))}
  </Stack>
)

export default MessagesBox
