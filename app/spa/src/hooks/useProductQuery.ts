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
      numberOfBlocks
      averageSpeed
      averageQueueTime
      averageTouchTime
      leadtimeP95
      leadtimeP80
      leadtimeP65

      latestDeliveries {
        id
        customerName
        productName
        endDate
        leadtime
        demandBlocks
      }

      company {
        id
        name
        slug
      }
    }
  }
`

const useProductQuery = (slug: string) => {
  const { data, loading, error } = useQuery<Product>(PRODUCT_QUERY, {
    variables: { slug },
  })

  return { product: data, loading, error }
}

export default useProductQuery
