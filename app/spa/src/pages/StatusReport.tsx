import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Typography, Box } from "@mui/material"
import { useParams } from "react-router-dom"

import BasicPage from "../components/BasicPage"
import { Project } from "../components/ReplenishingProjectsInfo"
import Ticket from "../components/Ticket"
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

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={data?.project.company}
    >
      <Box>
        <Typography component="h2" variant="h6" mb={3}>
          Números Atuais
        </Typography>
        <Box sx={{ display: "flex", justifyContent: "space-evenly" }}>
          <Ticket title="Custo" value={data?.project.currentCost} />
          <Ticket
            title="Esforço"
            value={data?.project.totalHoursConsumed?.toFixed(2)}
          />
          <Ticket
            title="Velocidade média"
            value={data?.project.averageSpeed?.toFixed(2)}
          />
          <Ticket
            title="Idade média dos itens"
            value={data?.project.averageDemandAging?.toFixed(2)}
          />
        </Box>
      </Box>
      <Box>
        <Typography component="h2" variant="h6" mb={3}>
          Mudanças no Prazo
        </Typography>
        <Box sx={{ display: "flex", justifyContent: "space-evenly" }}>
          <Ticket title="Prazo atual" value={data?.project.endDate} />
          <Ticket title="Primeiro prazo" value={data?.project.firstDeadline} />
          <Ticket
            title="Última diferença"
            value={data?.project.daysDifferenceBetweenFirstAndLastDeadlines}
          />
          <Ticket
            title="Quantidade de mudanças"
            value={data?.project.deadlinesChangeCount}
          />
        </Box>
      </Box>
      <Box>
        <Typography component="h2" variant="h6" mb={3}>
          Fluxo
        </Typography>
        <Box sx={{ display: "flex", justifyContent: "space-evenly" }}>
          <Ticket title="Entrega" value={data?.project.totalThroughput} />
          <Ticket
            title="Backlog restante"
            value={data?.project.remainingBacklog}
          />
          <Ticket title="Carga de falha" value={data?.project.failureLoad} />
          <Ticket
            title="Leadtime (80%)"
            value={leadtime && formatLeadtime(leadtime)}
          />
        </Box>
      </Box>
    </BasicPage>
  )
}

export default StatusReport
