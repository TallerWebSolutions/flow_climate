import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Box, Typography } from "@mui/material"
import { useParams } from "react-router-dom"
import { ResponsiveBar } from "@nivo/bar"
import { ResponsivePie } from "@nivo/pie"
import { dinero, toFormat } from "dinero.js"
import { BRL } from "@dinero.js/currencies"

import BasicPage from "../components/BasicPage"
import { Project } from "../components/ReplenishingProjectsInfo"
import TicketGroup from "../components/TicketGroup"
import { formatLeadtime } from "../lib/func"

export const QUERY = gql`
  query ProjectStatusReport($id: Int!) {
    project(id: $id) {
      id
      name
      endDate
      firstDeadline
      daysDifferenceBetweenFirstAndLastDeadlines
      deadlinesChangeCount
      currentCost
      totalHoursConsumed
      averageSpeed
      averageDemandAging
      totalThroughput
      remainingBacklog
      failureLoad
      leadTimeP80
      weeklyThroughputs
      company {
        id
        name
        slug
      }
    }
  }
`

type ProjectStatusReportResult = {
  project: Project
}

type ProjectStatusReportDTO = ProjectStatusReportResult | undefined

const StatusReport = () => {
  const { projectId } = useParams()
  const { data, loading, error } = useQuery<ProjectStatusReportDTO>(QUERY, {
    variables: {
      id: Number(projectId),
    },
  })

  if (error) {
    console.error(error)
  }

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const projectName = data?.project.name || ""
  const companyName = data?.project.company.name || ""
  const companySlug = data?.project.company.slug
  const breadcrumbsLinks = [
    { name: companyName, url: `/companies/${companySlug}` },
    { name: "Projetos", url: `/companies/${companySlug}/projects` },
    {
      name: projectName,
      url: `/companies/${companySlug}/projects/${data?.project.id}`,
    },
    {
      name: "Status Report",
    },
  ]
  const projectTabs = [
    {
      label: "Gráficos",
      to: `/companies/${companySlug}/projects/${projectId}`,
    },
    {
      label: "Estatísticas",
      to: `/companies/${companySlug}/projects/${projectId}/statistics_tab`,
    },
    {
      label: "Relatório de Status",
      to: `/companies/${companySlug}/projects/${projectId}/status_report_dashboard`,
    },
  ]

  const leadtime = data?.project.leadTimeP80
  const cost = Number(data?.project.currentCost.toFixed(2))
  const formattedCost = toFormat(
    dinero({ amount: cost, currency: BRL }),
    ({ amount }) => `R$ ${amount}`
  )

  const currentNumbersData = [
    { title: "Custo", value: formattedCost },
    {
      title: "Esforço",
      value: data?.project.totalHoursConsumed?.toFixed(2),
      unity: "horas",
    },
    {
      title: "Velocidade média",
      value: data?.project.averageSpeed?.toFixed(2),
      unity: "demandas/dia",
    },
    {
      title: "Idade média dos itens",
      value: data?.project.averageDemandAging?.toFixed(2),
      unity: "dias",
    },
  ]
  const deadlineChangesData = [
    { title: "Prazo atual", value: data?.project.endDate },
    { title: "Primeiro prazo", value: data?.project.firstDeadline },
    {
      title: "Última diferença",
      value: data?.project.daysDifferenceBetweenFirstAndLastDeadlines,
      unity: "dias",
    },
    {
      title: "Quantidade de mudanças",
      value: data?.project.deadlinesChangeCount,
    },
  ]
  const flowData = [
    { title: "Entrega", value: data?.project.totalThroughput, unity: "itens" },
    {
      title: "Backlog restante",
      value: data?.project.remainingBacklog,
      unity: "itens",
    },
    { title: "Carga de falha", value: data?.project.failureLoad, unity: "%" },
    {
      title: "Leadtime (80%)",
      value: leadtime && formatLeadtime(leadtime),
      unity: "dias",
    },
  ]
  const throughputData = data?.project.weeklyThroughputs.map((th, index) => ({
    week: `${th}--${index}`,
    id: `${th}--${index}`,
    throughput: th,
  }))
  const scope = data?.project.scope || 0
  const discoveredScope = data?.project.discoveredScope || 0
  const discoveryData = [
    {
      id: "Antes do início",
      value: scope - discoveredScope,
    },
    {
      id: "Depois do início",
      value: discoveredScope,
    },
  ]

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={data?.project.company}
      tabs={projectTabs}
    >
      <TicketGroup title="Números atuais" data={currentNumbersData} />
      <TicketGroup title="Mudanças no prazo" data={deadlineChangesData} />
      <TicketGroup title="Fluxo" data={flowData} />
      <Typography component="h2" variant="h5" mb={3}>
        Itens de Trabalho
      </Typography>
      <Box display="flex" pb={4} height={300}>
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            flexGrow: 1,
            flexBasis: 1,
          }}
        >
          <Typography component="h3" variant="h6" mb={3}>
            Descobertas
          </Typography>
          <ResponsivePie data={discoveryData} colors={{ scheme: "pastel2" }} />
        </Box>
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            flexGrow: 1,
            flexBasis: 1,
          }}
        >
          <Typography component="h3" variant="h6" mb={3}>
            Entregas
          </Typography>
          {throughputData && (
            <ResponsiveBar
              data={throughputData}
              colors={{ scheme: "pastel2" }}
              keys={["throughput"]}
              indexBy="week"
            />
          )}
        </Box>
      </Box>
    </BasicPage>
  )
}

export default StatusReport
