import { gql, useQuery } from "@apollo/client"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { formatCurrency } from "../../lib/currency"
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
    }
  }
`

type CustomerDemandDTO = {
  demand?: Demand
}

const CustomerDemand = () => {
  const { t } = useTranslation("customer")
  const params = useParams()
  const { data, loading } = useQuery<CustomerDemandDTO>(CUSTOMER_DEMAND_QUERY, {
    variables: { externalId: params?.demand },
  })
  const demand = data?.demand

  const breadcrumbsLinks = [
    { name: t("dashboard.title") || "", url: "/" },
    {
      name: demand?.externalId || "",
    },
  ]

  const headerCells = [
    t("customerDemands.externalId"),
    t("customerDemands.effortUpstream"),
    t("customerDemands.effortDownstream"),
    t("customerDemands.costToProject"),
  ]

  const rows = [
    [
      demand?.externalId || "",
      demand?.effortUpstream?.toFixed(2) || "",
      demand?.effortDownstream?.toFixed(2) || "",
      formatCurrency(demand?.costToProject || 0),
    ],
  ]

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
      title={demand?.demandTitle}
    >
      <Table headerCells={headerCells} rows={rows} />
    </BasicPage>
  )
}

export default CustomerDemand
