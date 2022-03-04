import { formatCurrency } from "../currency"

describe("Formatted cost", () => {
  it("should formart with zero cost", () => {
    const data = {
      project: {
        currentCost: 0,
      },
    }

    const cost = Number(data?.project.currentCost.toFixed(2))
    const formattedCost = formatCurrency(cost)

    expect(formattedCost).toBe("R$ 0,00")
  })

  it("should formart with less than zero cost", () => {
    const data = {
      project: {
        currentCost: 0.99,
      },
    }

    const cost = Number(data?.project.currentCost)
    const formattedCost = formatCurrency(cost)

    expect(formattedCost).toBe("R$ 0,99")
  })

  it("should formart zero", () => {
    const data = {
      project: {
        currentCost: 1.24,
      },
    }

    const cost = Number(data?.project.currentCost)
    const formattedCost = formatCurrency(cost)

    expect(formattedCost).toBe("R$ 1,24")
  })

  it("should formart on hundred of cost", () => {
    const data = {
      project: {
        currentCost: 161909.99,
      },
    }

    const cost = Number(data?.project.currentCost.toFixed(2))
    const formattedCost = formatCurrency(cost)

    expect(formattedCost).toBe("R$ 161.909,99")
  })
})
