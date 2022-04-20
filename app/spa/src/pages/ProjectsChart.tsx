import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  Box,
  CircularProgress,
  Grid,
  Typography,
} from "@mui/material"
import { useTranslation } from "react-i18next"
import { useParams } from "react-router-dom"
import { LineChart } from "../components/charts/LineChart"
import { ProjectChartsTable } from "../components/ProjectChartsTable"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../components/ProjectPage"
import { secondsToDays } from "../lib/date"
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

      projectConsolidationsWeekly {
        leadTimeP80
        projectQuality
        consolidationDate
      }
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
  const { data, loading } = useQuery<ProjectChartDTO>(PROJECT_CHART_QUERY, {
    variables: {
      projectId: Number(projectId),
      limit: LIMIT_DEMANDS_PER_PAGE,
    },
  })

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const project = data?.project!
  const projectConsolidationsWeekly = project.projectConsolidationsWeekly
  const demands = data?.demands!

  const leadTimeP80ChartData = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(({ leadTimeP80 }, index) => {
        const leadTimep80InDays = secondsToDays(leadTimeP80)

        return {
          x: index,
          y: leadTimep80InDays,
        }
      }),
    },
  ]

  const projectQualityChartData = [
    {
      id: project.name,
      data: projectConsolidationsWeekly.map(
        ({ consolidationDate, projectQuality }) => {
          const qualityPercentage = ((1 - projectQuality) * 100).toFixed(2)

          return {
            x: consolidationDate,
            y: qualityPercentage,
          }
        }
      ),
    },
  ]

  console.log({ projectQualityChartData })

  return (
    <ProjectPage pageName={t("charts")} project={project}>
      <ProjectChartsTable project={project} demands={demands} />

      <Grid container spacing={2} sx={{ marginTop: "32px" }}>
        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>Lead Time (p80)</Typography>

            <LineChart data={leadTimeP80ChartData} axisLeftLegend={"Days"} />
          </Box>
        </Grid>

        <Grid item xs={6} sx={{ padding: "8px" }}>
          <Box sx={{ height: "350px" }}>
            <Typography>Quality: Bugs</Typography>

            <LineChart data={projectQualityChartData} axisLeftLegend={"Days"} />
          </Box>
        </Grid>
      </Grid>
    </ProjectPage>
  )
}

export default ProjectsChart
