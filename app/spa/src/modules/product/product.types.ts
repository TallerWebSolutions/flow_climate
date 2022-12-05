export type Product = {
  id: string
  name: string
}

export type ProductInfo = {
  product: {
    id: number
    name: string
    slug: string
    company: {
      id: string
      name: string
      slug: string
    }
  }
}
