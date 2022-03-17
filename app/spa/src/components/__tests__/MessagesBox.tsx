import { render, screen, fireEvent } from "@testing-library/react"

import MessagesBox from "../MessagesBox"

describe("components/MessagesBox", () => {
  const messages = [
    {
      severity: "info",
      text: "this is an alert, dumbass",
    },
    {
      severity: "error",
      text: "this is a danger alert, dumbass",
    },
  ]

  it("should render in happy case", () => {
    render(<MessagesBox messages={messages} />)
  })

  it("should render one box for each message", () => {
    render(<MessagesBox messages={messages} />)

    const items = screen.queryAllByTestId("message-box")
    expect(items).toHaveLength(2)
  })
})
