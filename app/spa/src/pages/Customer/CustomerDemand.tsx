import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"

import DemandBasicPage from "../../modules/demand/components/DemandBasicPage"
import { Demand } from "../../modules/demand/demand.types"

const CUSTOMER_DEMAND_QUERY = gql`
  query CustomerDemand($externalId: String!) {
    demand(externalId: $externalId) {
      id
      demandTitle
      externalId
      effortUpstream
      effortDownstream
      costToProject
      createdDate
      commitmentDate
      endDate
    }
  }
`

type CustomerDemandDTO = {
  demand?: Demand
}

const CustomerDemand = () => {
  const params = useParams()
  const { data, loading } = useQuery<CustomerDemandDTO>(CUSTOMER_DEMAND_QUERY, {
    variables: { externalId: params?.demand },
  })

  const demand = data?.demand

  return demand ? <DemandBasicPage demand={demand} loading={loading} /> : null
}

export default CustomerDemand
