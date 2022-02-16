import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Typography } from "@mui/material"
import { useParams } from "react-router-dom"

import BasicPage from "../components/BasicPage"
import { Project } from "../components/ReplenishingProjectsInfo"
import Ticket from "../components/Ticket"

export const QUERY = gql`
  query ProjectStatusReport($id: Int!) {
    project(id: $id) {
      id
      name
      endDate
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

  return (
    <BasicPage
      title={projectName}
      breadcrumbsLinks={breadcrumbsLinks}
      company={data?.project.company}
    >
      <Typography component="h2" variant="h6" mb={3}>
        Mudanças no Prazo
      </Typography>
      <Ticket title="Prazo Atual" value={data?.project.endDate || ""} />
    </BasicPage>
  )
}

export default StatusReport
