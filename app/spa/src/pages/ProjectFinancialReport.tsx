import { useParams } from "react-router-dom"
import { Container, Backdrop, CircularProgress, Link } from "@mui/material"
import { gql, useQuery } from "@apollo/client"
import { ProjectPage } from "../components/ProjectPage"
import Table from "../components/Table"
import { formatCurrency } from "../lib/currency"
import { formatDate } from "../lib/date"
import { useTranslation } from "react-i18next"

const QUERY = gql`
  query FinancialReportDemands($projectId: Int!) {
    finishedDemands: demands(
      projectId: $projectId
      limit: 100
      finished: true
    ) {
      id
      externalId
      demandTitle
      endDate
      costToProject
      effortDownstream
      effortUpstream
    }

    discardedDemands: demands(
      projectId: $projectId
      limit: 100
      discarded: true
      finished: false
    ) {
      id
      externalId
      demandTitle
      costToProject
      effortDownstream
      effortUpstream
    }
  }
`

type Demand = {
  id: string
  externalId: string
  demandTitle: string
  endDate?: string
  costToProject: number
  effortDownstream: number
  effortUpstream: number
}

type FinancialReportDemandsDTO = {
  finishedDemands: Demand[]
  discardedDemands: Demand[]
}

const sum = (a: number, b: number) => a + b

const ProjectFinancialReport = () => {
  const { t } = useTranslation(["projectFinancialReport"])
  const { projectId, companyNickName } = useParams()
  const { data, loading } = useQuery<FinancialReportDemandsDTO>(QUERY, {
    variables: {
      projectId: Number(projectId),
    },
  })

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const finishedDemandsRows = data?.finishedDemands
    ? data.finishedDemands.map((demand) => [
        <Link
          href={`/companies/${companyNickName}/demands/${demand.externalId}`}
        >
          {demand.externalId}
        </Link>,
        demand.demandTitle,
        demand.endDate
          ? formatDate({ date: demand.endDate, format: "dd/MM/yy" })
          : "",
        formatCurrency(demand.costToProject),
        Number(demand.effortUpstream).toFixed(2),
        Number(demand.effortDownstream).toFixed(2),
        Number(demand.effortUpstream + demand.effortDownstream).toFixed(2),
      ])
    : []

  const totalFinishedDemandsCost =
    data?.finishedDemands
      .map((demand) => demand.costToProject)
      .reduce(sum, 0) || 0
  const totalFinishedDemandsUpstreamEffort =
    data?.finishedDemands
      .map((demand) => demand.effortUpstream)
      .reduce(sum, 0) || 0
  const totalFinishedDemandsDownstreamEffort =
    data?.finishedDemands
      .map((demand) => demand.effortDownstream)
      .reduce(sum, 0) || 0
  const finishedDemandsFooter = [
    t("footer.total"),
    "",
    "",
    formatCurrency(totalFinishedDemandsCost),
    totalFinishedDemandsUpstreamEffort.toFixed(2),
    totalFinishedDemandsDownstreamEffort.toFixed(2),
    (
      totalFinishedDemandsUpstreamEffort + totalFinishedDemandsDownstreamEffort
    ).toFixed(2),
  ]

  const discardedDemandsRows = data?.discardedDemands
    ? data.discardedDemands.map((demand) => [
        <Link
          href={`/companies/${companyNickName}/demands/${demand.externalId}`}
        >
          {demand.externalId}
        </Link>,
        demand.demandTitle,
        formatCurrency(demand.costToProject),
        Number(demand.effortUpstream).toFixed(2),
        Number(demand.effortDownstream).toFixed(2),
        Number(demand.effortUpstream + demand.effortDownstream).toFixed(2),
      ])
    : []

  const totalDiscardedDemandsCost =
    data?.discardedDemands
      .map((demand) => demand.costToProject)
      .reduce(sum, 0) || 0
  const totalDiscardedDemandsUpstreamEffort =
    data?.discardedDemands
      .map((demand) => demand.effortUpstream)
      .reduce(sum, 0) || 0
  const totalDiscardedDemandsDownstreamEffort =
    data?.discardedDemands
      .map((demand) => demand.effortDownstream)
      .reduce(sum, 0) || 0

  const discardedDemandsFooter = [
    t("footer.total"),
    "",
    formatCurrency(totalDiscardedDemandsCost),
    totalDiscardedDemandsUpstreamEffort.toFixed(2),
    totalDiscardedDemandsDownstreamEffort.toFixed(2),
    (
      totalDiscardedDemandsUpstreamEffort +
      totalDiscardedDemandsDownstreamEffort
    ).toFixed(2),
  ]

  return (
    <ProjectPage pageName={t("title")}>
      <Container>
        <Table
          title={t("finishedDemands.title")}
          headerCells={[
            t("finishedDemands.code").toString(),
            t("finishedDemands.demandTitle").toString(),
            t("finishedDemands.deliveryDate").toString(),
            t("finishedDemands.cost").toString(),
            t("finishedDemands.effortUpstream").toString(),
            t("finishedDemands.effortDownstream").toString(),
            t("finishedDemands.totalEffort").toString(),
          ]}
          rows={finishedDemandsRows}
          footerCells={finishedDemandsFooter}
        />
        <Table
          title="Demandas Descartadas"
          headerCells={[
            t("discardedDemands.code").toString(),
            t("discardedDemands.demandTitle").toString(),
            t("discardedDemands.cost").toString(),
            t("discardedDemands.effortUpstream").toString(),
            t("discardedDemands.effortDownstream").toString(),
            t("discardedDemands.totalEffort").toString(),
          ]}
          rows={discardedDemandsRows}
          footerCells={discardedDemandsFooter}
        />
      </Container>
    </ProjectPage>
  )
}

export default ProjectFinancialReport
