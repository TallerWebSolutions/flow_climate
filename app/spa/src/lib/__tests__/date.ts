import { secondsToReadbleDate } from "../date"

describe("secondsToReadbleDate", () => {
  it("should '86400's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(86400)).toBe("1 dia")
  })

  it("should '174410's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(174410)).toBe("2 dias")
  })
})
