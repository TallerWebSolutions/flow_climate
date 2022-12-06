import { gql, useQuery } from "@apollo/client"
import { Product } from "../modules/product/product.types"

const PRODUCT_QUERY = gql`
  query ProductInfo($slug: String!) {
    product(slug: $slug) {
      id
      name
      slug
      createdDemandsCount
      deliveredDemandsCount
      remainingBacklogCount
      upstreamDemandsCount
      downstreamDemandsCount
      discardedDemandsCount
      unscoredDemandsCount
      demandsBlocksCount
      averageSpeed
      averageQueueTime
      averageTouchTime
      leadtimeP95
      leadtimeP80
      leadtimeP65

      latestDeliveries {
        id
        externalId
        customerName
        productName
        projectName
        endDate
        leadtime
        demandBlocksCount
      }

      company {
        id
        name
        slug
      }
    }
  }
`

type ProductDTO = {
  product: Product
}

const useProductQuery = (slug: string) => {
  const { data, loading, error } = useQuery<ProductDTO>(PRODUCT_QUERY, {
    variables: { slug },
  })

  return { product: data?.product, loading, error }
}

export default useProductQuery
