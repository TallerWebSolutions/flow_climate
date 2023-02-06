import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"

import DemandBasicPage from "../../modules/demand/components/DemandBasicPage"
import { Demand as DemandType } from "../../modules/demand/demand.types"

const DEMAND_QUERY = gql`
  query Demand($externalId: String!) {
    demand(externalId: $externalId) {
      id
      demandTitle
      externalId
      effortUpstream
      effortDownstream
      costToProject
    }
  }
`

type DemandDTO = {
  demand?: DemandType
}

const Demand = () => {
  const params = useParams()
  const { data, loading } = useQuery<DemandDTO>(DEMAND_QUERY, {
    variables: { externalId: params?.demand },
  })

  const demand = data?.demand

  return demand ? <DemandBasicPage demand={demand} loading={loading} /> : null
}

export default Demand
