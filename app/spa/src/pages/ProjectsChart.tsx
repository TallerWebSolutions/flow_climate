import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Grid, Link, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TablePagination, TableRow, Typography } from "@mui/material"
import { useState } from "react"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { ProjectPage, PROJECT_STANDARD_FRAGMENT } from "../components/ProjectPage"
import { formatDate, secondsToReadbleDate } from "../lib/date"
import { Project } from "../modules/project/project.types"

const LIMIT_DEMANDS_PER_PAGE = 7
const INITIAL_PAGE = 0

export const PROJECT_CHART_QUERY = gql`
  query ProjectCharts($projectId: Int!, $limit: Int!, $page: Int!) {
    project(id: $projectId) {
      id
      ...ProjectStandardFragment
      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
    }  
    demands(projectId: $projectId, limit: $limit, page: $page, finished: true) {
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

type Demand = {
  id: string
  endDate: string
  product: {
    id: string
    name: string
  }
  customer: {
    id: string
    name: string
  }
  externalId: string
  leadtime: number
  numberOfBlocks: number
}

type ProjectChartResult = {
  project: Project
  demands: Demand[]
}

type ProjectChartDTO = ProjectChartResult | undefined

const ProjectsChart = () => {
  const { t } = useTranslation(["projectChart"])
  const [initialPage, setInitialPage] = useState(INITIAL_PAGE)
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectChartDTO>(
    PROJECT_CHART_QUERY,
    {
      variables: {
        projectId: Number(projectId),
        limit: LIMIT_DEMANDS_PER_PAGE,
        page: initialPage
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
      <Grid item xs={4}>
        0
      </Grid>
      <Grid item xs={8}>
      <TableContainer component={Paper}
        sx={{
          background: "white",
          p: '16px',
        }}
      >
      <Typography color="primary" variant="h6" component="h6">
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
        <TablePagination
        labelDisplayedRows={({ from, to, count }) => {
          return `${from}-${to} ${t(
            "project_chart_table.count_displayed_items_separator"
          )} ${count}`
        }}
        rowsPerPageOptions={[LIMIT_DEMANDS_PER_PAGE]}
        component="div"
        count={20}
        rowsPerPage={LIMIT_DEMANDS_PER_PAGE}
        page={initialPage}
        onPageChange={(_, page) => setInitialPage(page)}
      />
      </TableContainer>
      </Grid>
    </Grid>
    </ProjectPage>
  )
}

export default ProjectsChart