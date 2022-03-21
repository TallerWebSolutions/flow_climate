import { formatDate, secondsToReadbleDate } from "../date"

describe("secondsToReadbleDate", () => {
  it("should '86400's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(86400)).toBe("1 dia")
  })

  it("should '174410's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(174410)).toBe("2 dias")
  })

  it("should '129600's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(129600)).toBe("1 dia e 12 horas")
  })

  it("should '45000's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(45000)).toBe("12 horas e 30 minutos")
  })

  it("should '360's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(360)).toBe("6 minutos")
  })

  it("should '45's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(45)).toBe("45 segundos")
  })

  it("should '0's be formated to readble human PTBR format", () => {
    expect(secondsToReadbleDate(0)).toBe("0 segundos")
  })

  it("should format zero to readble", () => {
    expect(secondsToReadbleDate(null)).toBe("0 segundos")
  })
})

describe("formatDate", () => {
  it("should format the date according to the format passed when its ISO", () => {
    const date = new Date("2022-03-21T00:00:40-03:00").toLocaleString("pr-BR", {
      timeZone: "America/Sao_Paulo",
    })

    expect(formatDate({ date: date, format: "dd/MM/yyyy' às 'HH:mm" })).toBe(
      "21/03/2022 às 00:00"
    )
  })

  it("should format the date according to the format passed when its DateTime", () => {
    const date = new Date("2022-03-21T00:00:40-03:00").toLocaleString("pr-BR", {
      timeZone: "America/Sao_Paulo",
    })

    expect(formatDate({ date: date, format: "dd/MM/yyyy' às 'HH:mm" })).toBe(
      "21/03/2022 às 00:00"
    )
  })
})
