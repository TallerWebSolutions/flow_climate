import { ReactElement } from "react"
import { useTranslation } from "react-i18next"
import { useLocation, useParams } from "react-router-dom"

import BasicPage from "../../../components/BasicPage"
import { Tabs } from "../../../components/Tabs"
import Table from "../../../components/ui/Table"
import { formatCurrency } from "../../../lib/currency"
import { Demand } from "../demand.types"

type DemandBasicPageProps = {
  demand: Demand
  loading: boolean
  children?: ReactElement
}

const DemandBasicPage = ({
  demand,
  loading,
  children,
}: DemandBasicPageProps) => {
  const { t } = useTranslation("demand")
  const { pathname } = useLocation()
  const params = useParams()

  const breadcrumbsLinks = [
    { name: t("dashboard.title") || "", url: "/" },
    {
      name: demand?.externalId || "",
    },
  ]

  const headerCells = [
    t("table.header.id"),
    t("table.header.effortUpstream"),
    t("table.header.effortDownstream"),
    t("table.header.costToProject"),
  ]

  const rows = [
    [
      demand?.externalId || "",
      demand?.effortUpstream?.toFixed(2) || "",
      demand?.effortDownstream?.toFixed(2) || "",
      formatCurrency(demand?.costToProject || 0),
    ],
  ]

  const demandPath = `/companies/${params.company}/demands/${params.demand}`
  const tabs = [
    {
      label: t("tabs.blocks"),
      to: demandPath,
    },
    {
      label: t("tabs.responsibles"),
      to: demandPath,
    },
    {
      label: t("tabs.comments"),
      to: demandPath,
    },
    {
      label: t("tabs.structure"),
      to: demandPath,
    },
    {
      label: t("tabs.flowEfficiency"),
      to: demandPath,
    },
    {
      label: t("tabs.transitions"),
      to: demandPath,
    },
    {
      label: t("tabs.efforts"),
      to: `${demandPath}/demand_efforts`,
    },
  ]

  return (
    <BasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      title={demand?.demandTitle}
      loading={loading}
    >
      <Table headerCells={headerCells} rows={rows} />
      <Tabs currentPath={pathname} tabs={tabs} />
      {children}
    </BasicPage>
  )
}

export default DemandBasicPage
