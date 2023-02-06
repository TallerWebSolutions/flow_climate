import { useTranslation } from "react-i18next"
import BasicPage from "../../../components/BasicPage"
import Table from "../../../components/ui/Table"
import { formatCurrency } from "../../../lib/currency"
import { Demand } from "../demand.types"

type DemandBasicPageProps = {
  demand: Demand
  loading: boolean
}

const DemandBasicPage = ({ demand, loading }: DemandBasicPageProps) => {
  const { t } = useTranslation("customer")

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
      title={demand?.demandTitle}
      loading={loading}
    >
      <Table headerCells={headerCells} rows={rows} />
    </BasicPage>
  )
}

export default DemandBasicPage
