import { toFormat } from "dinero.js"
import { currencyFromFloat } from "../currency"

describe("Formatted cost", () => {
  it("should formart with zero cost", () => {
    const data = {
      project: {
        currentCost: 0,
      },
    }

    const cost = Number(data?.project.currentCost.toFixed(2))

    const formattedCost = toFormat(
      currencyFromFloat({ amount: cost }),
      ({ amount }) => `R$ ${amount}`
    )

    expect(formattedCost).toBe("R$ 0")
  })

  it("should formart with less than R$1 cost", () => {
    const data = {
      project: {
        currentCost: 0.99,
      },
    }

    const cost = Number(data?.project.currentCost.toFixed(2))

    const formattedCost = toFormat(
      currencyFromFloat({ amount: cost }),
      ({ amount }) => `R$ ${amount}`
    )

    expect(formattedCost).toBe("R$ 0.99")
  })

  it("should formart zero", () => {
    const data = {
      project: {
        currentCost: 1.24,
      },
    }

    const cost = Number(data?.project.currentCost.toFixed(2))

    const formattedCost = toFormat(
      currencyFromFloat({ amount: cost }),
      ({ amount }) => `R$ ${amount}`
    )

    expect(formattedCost).toBe("R$ 1.24")
  })
})
