import ProjectBurnup from "./ProjectBurnup"
import ProjectHoursBurnup from "./ProjectHoursBurnup"
import ProjectLeadTime from "./ProjectLeadTime"
import ProjectLeadTimeControlChart from "./ProjectLeadTimeControlChart"
import ProjectBugsPercentage from "./ProjectBugsPercentage"
import ProjectCumulativeFlowData from "./ProjectCumulativeFlowData"
import { Grid } from "@mui/material"
import { Project } from "../../../modules/project/project.types"
import ProjectOperationalRiskEvolution from "./ProjectOperationalRiskEvolution"
import ProjectDeliveriesByClassOfService from "./ProjectDeliveriesByClassOfService"

const ProjectStatusReportCharts = ({
  project,
}: ProjectStatusReportChartsProps) => {
  return (
    <Grid container spacing={2} rowSpacing={8}>
      <ProjectBurnup project={project} />
      <ProjectHoursBurnup project={project} />
      <ProjectLeadTime project={project} />
      <ProjectLeadTimeControlChart project={project} />
      <ProjectBugsPercentage project={project} />
      <ProjectCumulativeFlowData project={project} />
      <ProjectOperationalRiskEvolution project={project} />
      <ProjectDeliveriesByClassOfService project={project} />
    </Grid>
  )
}

type ProjectStatusReportChartsProps = {
  project: Project
}

export default ProjectStatusReportCharts
