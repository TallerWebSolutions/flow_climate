import { useParams, Link as RouterLink } from "react-router-dom"
import { Container, Link, Button } from "@mui/material"
import { gql, useQuery } from "@apollo/client"
import { ProjectPage } from "../../components/ProjectPage"
import Table from "../../components/ui/Table"
import { formatCurrency } from "../../lib/currency"
import { formatDate } from "../../lib/date"
import { useTranslation } from "react-i18next"
import { DemandsList } from "../../modules/demand/demand.types"

const QUERY = gql`
  query FinancialReportDemands($projectId: ID!) {
    finishedDemands: demandsList(
      searchOptions: {
        projectId: $projectId
        perPage: 100
        demandStatus: DELIVERED_DEMANDS
        sortDirection: ASC
        orderField: "end_date"
      }
    ) {
      demands {
        id
        externalId
        demandTitle
        endDate
        costToProject
        effortDownstream
        effortUpstream
      }
    }

    discardedDemands: demandsList(
      searchOptions: {
        projectId: $projectId
        perPage: 100
        demandStatus: DISCARDED_DEMANDS
        sortDirection: ASC
        orderField: "created_date"
      }
    ) {
      demands {
        id
        externalId
        demandTitle
        costToProject
        effortDownstream
        effortUpstream
      }
    }

    projectAdditionalHours(projectId: $projectId) {
      id
      eventDate
      hours
      obs
      project {
        id
        name
      }
    }
  }
`

type AdditionalHours = {
  eventDate: string
  hours: number
  obs: string
  project: {
    id: string
    name: string
  }
}

type FinancialReportDemandsDTO = {
  finishedDemands: DemandsList
  discardedDemands: DemandsList
  projectAdditionalHours: AdditionalHours[]
}

const sum = (a: number, b: number) => a + b

const ProjectFinancialReport = () => {
  const { t, i18n } = useTranslation(["projectFinancialReport"])
  const dateFormat = i18n.language === "pt-BR" ? "dd/MM/yy" : "MM/dd/yy"
  const { projectId, companySlug } = useParams()
  const { data, loading } = useQuery<FinancialReportDemandsDTO>(QUERY, {
    variables: {
      projectId,
    },
  })

  const finishedDemandsRows = data?.finishedDemands
    ? data.finishedDemands.demands.map((demand) => [
        <Link href={`/companies/${companySlug}/demands/${demand.externalId}`}>
          {demand.externalId}
        </Link>,
        String(demand.demandTitle),
        demand.endDate
          ? formatDate({ date: demand.endDate, format: dateFormat })
          : "",
        formatCurrency(demand.costToProject || 0),
        Number(demand.effortUpstream || 0).toFixed(2),
        Number(demand.effortDownstream || 0).toFixed(2),
        Number(
          (demand.effortUpstream || 0) + (demand.effortDownstream || 0)
        ).toFixed(2),
      ])
    : []

  const totalFinishedDemandsCost =
    data?.finishedDemands.demands
      .map((demand) => demand.costToProject || 0)
      .reduce(sum, 0) || 0
  const totalFinishedDemandsUpstreamEffort =
    data?.finishedDemands.demands
      .map((demand) => demand.effortUpstream || 0)
      .reduce(sum, 0) || 0
  const totalFinishedDemandsDownstreamEffort =
    data?.finishedDemands.demands
      .map((demand) => demand.effortDownstream || 0)
      .reduce(sum, 0) || 0
  const finishedDemandsFooter = [
    t("footer.total"),
    `${finishedDemandsRows.length} ${t("footer.demands")}`,
    "",
    formatCurrency(totalFinishedDemandsCost),
    totalFinishedDemandsUpstreamEffort.toFixed(2),
    totalFinishedDemandsDownstreamEffort.toFixed(2),
    (
      totalFinishedDemandsUpstreamEffort + totalFinishedDemandsDownstreamEffort
    ).toFixed(2),
  ]

  const discardedDemandsRows = data?.discardedDemands?.demands
    ? data.discardedDemands.demands.map((demand) => [
        <Link href={`/companies/${companySlug}/demands/${demand.externalId}`}>
          {demand.externalId}
        </Link>,
        String(demand.demandTitle),
        formatCurrency(demand.costToProject || 0),
        Number(demand.effortUpstream).toFixed(2),
        Number(demand.effortDownstream).toFixed(2),
        Number(
          (demand.effortUpstream || 0) + (demand.effortDownstream || 0)
        ).toFixed(2),
      ])
    : []

  const totalDiscardedDemandsCost =
    data?.discardedDemands.demands
      .map((demand) => demand.costToProject || 0)
      .reduce(sum, 0) || 0
  const totalDiscardedDemandsUpstreamEffort =
    data?.discardedDemands.demands
      .map((demand) => demand.effortUpstream || 0)
      .reduce(sum, 0) || 0
  const totalDiscardedDemandsDownstreamEffort =
    data?.discardedDemands.demands
      .map((demand) => demand.effortDownstream || 0)
      .reduce(sum, 0) || 0

  const discardedDemandsFooter = [
    t("footer.total"),
    `${discardedDemandsRows.length} ${t("footer.demands")}`,
    formatCurrency(totalDiscardedDemandsCost),
    totalDiscardedDemandsUpstreamEffort.toFixed(2),
    totalDiscardedDemandsDownstreamEffort.toFixed(2),
    (
      totalDiscardedDemandsUpstreamEffort +
      totalDiscardedDemandsDownstreamEffort
    ).toFixed(2),
  ]

  const additionalHoursRows =
    data?.projectAdditionalHours.map((item) => [
      item.eventDate,
      item.hours,
      item.obs,
    ]) || []

  const totalAdditionalHours = data?.projectAdditionalHours
    .map((item) => item.hours)
    .reduce(sum, 0)

  const additionalHoursFooterCells = [
    t("footer.total").toString(),
    Number(totalAdditionalHours),
  ]

  return (
    <ProjectPage pageName={t("title")} loading={loading}>
      <Container
        sx={{ display: "flex", justifyContent: "flex-end", paddingY: 4 }}
      >
        <Button
          component={RouterLink}
          to={`/companies/${companySlug}/projects/${projectId}/project_additional_hours/new`}
          variant="contained"
        >
          {t("registerAdditionalHours")}
        </Button>
      </Container>
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
          title={t("discardedDemands.title")}
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
        <Table
          title={t("additionalHours.title").toString()}
          headerCells={[
            t("additionalHours.columns.eventDate").toString(),
            t("additionalHours.columns.hours").toString(),
            t("additionalHours.columns.obs").toString(),
          ]}
          rows={additionalHoursRows}
          footerCells={additionalHoursFooterCells}
        />
      </Container>
    </ProjectPage>
  )
}

export default ProjectFinancialReport
