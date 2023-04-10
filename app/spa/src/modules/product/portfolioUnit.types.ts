export type PortfolioUnit = {
  id?: number
  name?: string
  totalCost?: number
  totalHours?: number

  parent?: PortfolioUnit
}
