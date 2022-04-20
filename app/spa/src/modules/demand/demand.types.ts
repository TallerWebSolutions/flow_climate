export type Demand = {
  id: string
  endDate: string
  product: {
    id: string
    name: string
  }
  customer: {
    id: string
    name: string
  }
  externalId: string
  leadtime: number
  numberOfBlocks: number
}
