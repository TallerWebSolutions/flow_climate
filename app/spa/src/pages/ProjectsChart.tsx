import { gql, useQuery } from "@apollo/client"
import { Backdrop, Box, CircularProgress, Grid, Link, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography } from "@mui/material"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { ProjectPage, PROJECT_STANDARD_FRAGMENT } from "../components/ProjectPage"
import { formatDate, secondsToDays, secondsToReadbleDate } from "../lib/date"
import { Demand } from "../modules/demand/demand.types"
import { Project } from "../modules/project/project.types"

const LIMIT_DEMANDS_PER_PAGE = 10

export const PROJECT_CHART_QUERY = gql`
  query ProjectCharts($projectId: Int!, $limit: Int!) {
    project(id: $projectId) {
      ...ProjectStandardFragment
      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running

      startDate
      endDate
      initialScope
      numberOfDemands
      numberOfDemandsDelivered
      remainingBacklog
      upstreamDemands {
        id
      }
      numberOfDownstreamDemands
      discardedDemands {
        id
      }
      unscoredDemands {
        id
      }
      demandBlocks {
        id
      }
      flowPressure
      averageSpeed
      averageQueueTime
      averageTouchTime
      leadTimeP65
      leadTimeP80
      leadTimeP95
    }

    demands(projectId: $projectId, limit: $limit, finished: true) {
      id
      endDate
      product {
        id
        name
      }
      customer {
        id
        name
      }
      externalId
      leadtime
      numberOfBlocks
    }    
  }
  ${PROJECT_STANDARD_FRAGMENT}
`

type ProjectChartResult = {
  project: Project
  demands: Demand[]
}

type ProjectChartDTO = ProjectChartResult | undefined

const ProjectsChart = () => {
  const { t } = useTranslation(["projectChart"])
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectChartDTO>(
    PROJECT_CHART_QUERY,
    {
      variables: {
        projectId: Number(projectId),
        limit: LIMIT_DEMANDS_PER_PAGE,
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
  const demands = data?.demands!

  return (
    <ProjectPage pageName={t('charts')} project={project}>
      <Grid container spacing={2} sx={{marginTop: '32px'}}>
        <Grid item xs={4} sx={{ padding: '16px '}}>
        <TableContainer component={Paper} sx={{ background: "white" }}>
          <Typography color="primary" variant="h6" component="h6" sx={{ padding: '16px '}}>
            Informações gerais
          </Typography>
          <Table>
            <TableRow
              sx={{
                borderBottom: "1px solid",
                borderBottomColor: "#ccc",
              }}
            >
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Início</Box>
                {formatDate({ date: project.startDate, format: "dd/MM/yyyy" })}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Fim</Box>
                {formatDate({ date: project.endDate, format: "dd/MM/yyyy" })}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Escopo inicial</Box>
                {project.initialScope}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Demandas Criadas</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.numberOfDemands}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Entregas</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.numberOfDemandsDelivered}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Backlog</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.remainingBacklog}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Upstream</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.upstreamDemands.length}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Downstream</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.numberOfDownstreamDemands}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Descartadas</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.discardedDemands.length}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Demandas sem Pontuação</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.unscoredDemands.length}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Bloqueios</Box>
                <Link href={'#'} sx={{color: 'info.dark', textDecoration: 'none'}} >{project.demandBlocks.length}</Link>
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Pressão do Fluxo</Box>
                {`${secondsToReadbleDate(project.flowPressure, 'demandas/')}`}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Velocidade Média</Box>
                {`${project.averageSpeed.toFixed(3)} demandas/dia`}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Tempo Médio de Fila</Box>
                {`${project.averageQueueTime.toFixed(2)} horas`}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Tempo Médio de Trabalho</Box>
                {`${project.averageTouchTime.toFixed(2)} horas`}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Lead time p95</Box>
                {`${project.leadTimeP95.toFixed(2)} dias`}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Lead time p80</Box>
                {`${project.leadTimeP80.toFixed(2)} dias`}
              </TableCell>
              <TableCell align="left" sx={{padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between'}}>
                <Box component="span">Lead time p65</Box>
                {`${project.leadTimeP65.toFixed(2)} dias`}
              </TableCell>
            </TableRow>
          </Table>
        </TableContainer>
        </Grid>
        <Grid item xs={8} sx={{ padding: '16px '}}>
        <TableContainer component={Paper} sx={{ background: "white" }}>
        <Typography color="primary" variant="h6" component="h6" sx={{ padding: '16px '}}>
          {t('project_chart_table.latest_deliveries')}
        </Typography>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('project_chart_table.client')}</TableCell>
                <TableCell align="left">{t('project_chart_table.product')}</TableCell>
                <TableCell align="left">{t('project_chart_table.demand_id')}</TableCell>
                <TableCell align="left">{t('project_chart_table.delivery_date')}</TableCell>
                <TableCell align="left">{t('project_chart_table.leadtime')}</TableCell>
                <TableCell align="left">{t('project_chart_table.demand_blocks')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              
              {demands.map((demand) => {
                const baseLink = `/companies/${project?.company?.slug}`

                return (
                  <TableRow
                    sx={{
                      borderBottom: "1px solid",
                      borderBottomColor: "#ccc",
                    }}
                  >
                    <TableCell align="left" sx={{padding: '16px'}}>
                      <Link href={`${baseLink}/projects/${project.id}`} sx={{color: 'info.dark', textDecoration: 'none'}} >{demand.customer.name}</Link>
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                    <Link href={`${baseLink}/products/${demand.product.id}`} sx={{color: 'info.dark', textDecoration: 'none'}}>{demand.product.name}</Link>
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                    <Link href={`${baseLink}/demands/${demand.externalId}`} sx={{color: 'info.dark', textDecoration: 'none'}}>{demand.externalId}</Link>
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                      {formatDate({date: demand.endDate, format: "dd/MM/yyyy' 'HH:mm:ss"})}
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                      {secondsToReadbleDate(demand.leadtime)}
                    </TableCell>
                    <TableCell align="left" sx={{padding: '16px'}}>
                      {demand.numberOfBlocks}
                    </TableCell>
                </TableRow>
                )
              })} 
            </TableBody>
          </Table>        
        </TableContainer>
        </Grid>
    </Grid>
    </ProjectPage>
  )
}

export default ProjectsChart