import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Box, Typography } from "@mui/material"
import { useParams } from "react-router-dom"
import { Bar } from "@nivo/bar"
import { Pie } from "@nivo/pie"

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

  const leadtime = data?.project.leadTimeP80
  const currentNumbersData = [
    { title: "Custo", value: data?.project.currentCost },
    { title: "Esforço", value: data?.project.totalHoursConsumed?.toFixed(2) },
    {
      title: "Velocidade média",
      value: data?.project.averageSpeed?.toFixed(2),
    },
    {
      title: "Idade média dos itens",
      value: data?.project.averageDemandAging?.toFixed(2),
    },
  ]
  const deadlineChangesData = [
    { title: "Prazo atual", value: data?.project.endDate },
    { title: "Primeiro prazo", value: data?.project.firstDeadline },
    {
      title: "Última diferença",
      value: data?.project.daysDifferenceBetweenFirstAndLastDeadlines,
    },
    {
      title: "Quantidade de mudanças",
      value: data?.project.deadlinesChangeCount,
    },
  ]
  const flowData = [
    { title: "Entrega", value: data?.project.totalThroughput },
    { title: "Backlog restante", value: data?.project.remainingBacklog },
    { title: "Carga de falha", value: data?.project.failureLoad },
    { title: "Leadtime (80%)", value: leadtime && formatLeadtime(leadtime) },
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
    >
      <TicketGroup title="Números atuais" data={currentNumbersData} />
      <TicketGroup title="Mudanças no prazo" data={deadlineChangesData} />
      <TicketGroup title="Fluxo" data={flowData} />
      <Typography component="h2" variant="h5" mb={3}>
        Itens de Trabalho
      </Typography>
      <Box display="flex">
        <Box
          height={300}
          sx={{
            flexGrow: 1,
            flexBasis: 1,
          }}
        >
          <Typography component="h3" variant="h6" mb={3}>
            Descobertas
          </Typography>
          <Pie
            data={discoveryData}
            colors={{ scheme: "pastel2" }}
            width={400}
            height={300}
          />
        </Box>
        <Box
          height={300}
          sx={{
            flexGrow: 1,
            flexBasis: 1,
          }}
        >
          <Typography component="h3" variant="h6" mb={3}>
            Entregas
          </Typography>
          {throughputData && (
            <Bar
              data={throughputData}
              colors={{ scheme: "pastel2" }}
              keys={["throughput"]}
              indexBy="week"
              width={400}
              height={300}
            />
          )}
        </Box>
      </Box>
    </BasicPage>
  )
}

export default StatusReport
