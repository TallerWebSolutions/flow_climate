import { gql, useQuery } from "@apollo/client"
import { Product } from "../modules/product/product.types"

// @TODO: this hook should be replaced with page-specific queries, so they won't be too slow.
export const PRODUCT_QUERY = gql`
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
      portfolioUnitsCount
      averageSpeed
      averageQueueTime
      averageTouchTime
      leadtimeP95
      leadtimeP80
      leadtimeP65

      riskReviews {
        id
        leadTimeOutlierLimit
        meetingDate
        monthlyAvgBlockedTime
        weeklyAvgBlockedTime
        createdAt
      }

      latestDeliveries {
        id
        externalId
        customerName
        endDate
        leadtime
        demandBlocksCount
        product {
          id
          slug
          name
        }

        project {
          id
          name
        }
      }

      leadtimeEvolutionData {
        xAxis
        yAxisInMonth
        yAxisAccumulated
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
    notifyOnNetworkStatusChange: true,
  })

  return { product: data?.product, loading, error }
}

export default useProductQuery
