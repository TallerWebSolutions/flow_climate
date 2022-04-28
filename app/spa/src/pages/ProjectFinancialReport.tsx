import { Container } from "@mui/material"
import { ProjectPage } from "../components/ProjectPage"

const ProjectFinancialReport = () => {
  return (
    <ProjectPage pageName="Relatório Financeiro">
      <Container
        sx={{
          display: "flex",
          justifyContent: "center",
          alignItems: "center",
          height: "300px",
        }}
      >
        <strong>Coming soon</strong>
      </Container>
    </ProjectPage>
  )
}

export default ProjectFinancialReport
