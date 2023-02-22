import { gql, useQuery } from "@apollo/client"
import { Box, Typography } from "@mui/material"
import { useParams } from "react-router-dom"
import { ResponsiveBar } from "@nivo/bar"
import { ResponsivePie } from "@nivo/pie"
import TicketGroup from "../../components/TicketGroup"
import { formatCurrency } from "../../lib/currency"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../../components/ProjectPage"
import { Project } from "../../modules/project/project.types"
import { secondsToReadbleDate } from "../../lib/date"

export const QUERY = gql`
  query ProjectStatusReport($id: ID!) {
    project(id: $id) {
      ...ProjectStandardFragment

      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
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
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectStatusReportResult = {
  project: Project
}

type ProjectStatusReportDTO = ProjectStatusReportResult | undefined

const StatusReport = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectStatusReportDTO>(QUERY, {
    variables: {
      id: Number(projectId),
    },
  })

  const leadtime = data?.project.leadTimeP80
  const cost = Number(data?.project.currentCost)
  const formattedCost = formatCurrency(cost)

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
    {
      title: "Carga de falha",
      value: data?.project.failureLoad.toFixed(2),
      unity: "%",
    },
    {
      title: "Leadtime (80%)",
      value: leadtime && secondsToReadbleDate(leadtime),
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
    <ProjectPage pageName={"Status Report"} loading={loading}>
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
    </ProjectPage>
  )
}

export default StatusReport
