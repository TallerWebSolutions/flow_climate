import { capitalizeFirstLetter, formatLeadtime } from "../func"

describe("format leadtime", () => {
  it("should take leadtime data and format it to human readable info", () => {
    expect(formatLeadtime(339940.1788)).toEqual(3.93)
  })
})

describe("format string", () => {
  it("should make the first letter of string uppercase", () => {
    expect(capitalizeFirstLetter("name")).toEqual("Name")
  })
})
