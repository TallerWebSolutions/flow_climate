import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress } from "@mui/material"

import BasicPage from "../components/BasicPage"

const QUERY = gql`
  query ProjectStatusReport {
    projectById: project {
      id
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
  const {data, loading, error} = useQuery<ProjectStatusReportDTO>(QUERY)

  if (error) {
    console.error(error)
  }

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const projectName = "Projeto X"
  const breadcrumbsLinks = [
    { name: data.project.company.name, url: "" },
    { name: "Projetos", url: "" },
    { name: "IstoÉ - Matérias e Editorias", url: "" },
  ]

  return (
    <BasicPage title={projectName} breadcrumbsLinks={breadcrumbsLinks} />
  )
}

export default StatusReport
