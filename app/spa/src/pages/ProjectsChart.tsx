import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Grid, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography } from "@mui/material"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { ProjectPage, PROJECT_STANDARD_FRAGMENT } from "../components/ProjectPage"
import { Project } from "../modules/project/project.types"

export const PROJECT_CHART_QUERY = gql`
  query ProjectRiskDrill($id: Int!) {
    project(id: $id) {
      ...ProjectStandardFragment
      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectChartResult = {
  project: Project
}

type ProjectRiskDrillDTO = ProjectChartResult | undefined

const ProjectsChart = () => {
  const { t } = useTranslation(["projectChart"])
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectRiskDrillDTO>(
    PROJECT_CHART_QUERY,
    {
      variables: {
        id: Number(projectId),
      },
    }
  )

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const project = data?.project!

  const rows = []!

  return (
    <ProjectPage pageName={t('charts')} project={project}>
      <Grid container spacing={2}>
      <Grid item xs={4}>
        0
      </Grid>
      <Grid item xs={8}>
      <TableContainer component={Paper}>
      <Typography color="primary" variant="h6" component="h6">
        Últimas Entregas
      </Typography>
        <Table sx={{ minWidth: 650 }} size="small" aria-label="a dense table">
          <TableHead>
            <TableRow>
              <TableCell>Cliente</TableCell>
              <TableCell align="right">Produto</TableCell>
              <TableCell align="right">ID da demanda</TableCell>
              <TableCell align="right">Data de entrega</TableCell>
              <TableCell align="right">Leadtime</TableCell>
              <TableCell align="right">Bloqueios</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {rows.map((row) => (
              <TableRow
                key={row.name}
                sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
              >
                <TableCell component="th" scope="row">
                  {row.name}
                </TableCell>
                <TableCell align="right">{row.calories}</TableCell>
                <TableCell align="right">{row.fat}</TableCell>
                <TableCell align="right">{row.carbs}</TableCell>
                <TableCell align="right">{row.protein}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
      </Grid>
    </Grid>
    </ProjectPage>
  )
}

export default ProjectsChart