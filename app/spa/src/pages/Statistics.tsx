import { gql, useQuery } from "@apollo/client"
import { Backdrop, Box, CircularProgress, Typography } from "@mui/material"
import { ResponsiveLine, Serie } from "@nivo/line"
import { ReactElement, useEffect } from "react"
import { useParams } from "react-router-dom"
import { ProjectPage } from "../components/ProjectPage"
import {
  Project,
  ProjectConsolidation,
} from "../components/ReplenishingProjectsInfo"

const ONE_DAY_IN_SECONDS = 60 * 60 * 24

export const PROJECT_STATISTICS_QUERY = gql`
  query ProjectStatistics($id: Int!) {
    project(id: $id) {
      id
      name
      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
      company {
        id
        name
        slug
      }
    }

    projectConsolidations(projectId: $id, lastDataInWeek: true) {
      leadTimeRangeMonth
      leadTimeMinMonth
      leadTimeMaxMonth
    }
  }
`

type ProjectStatisticsResult = {
  project: Project
  projectConsolidations: ProjectConsolidation[]
}

type ProjectStatisticsDTO = ProjectStatisticsResult | undefined

type GraphBoxProps = {
  title: string
  children: ReactElement | ReactElement[]
}

const GraphBox = ({ title, children }: GraphBoxProps) => {
  return (
    <Box
      sx={{
        flex: "1 0 40%",
        display: "flex",
        alignItems: "center",
        flexDirection: "column",
        height: 350,
        padding: 1,
        my: 1,
      }}
    >
      <Typography component="h3" variant="h6" my={2}>
        {title}
      </Typography>
      {children}
    </Box>
  )
}

type LineGraphProps = {
  data: Serie[]
  axisLeftLegend: string
}

const LineGraph = ({ data, axisLeftLegend }: LineGraphProps) => {
  return (
    <ResponsiveLine
      data={data}
      colors={{ scheme: "pastel2" }}
      margin={{ left: 80, right: 20, top: 25, bottom: 40 }}
      axisLeft={{
        legend: axisLeftLegend,
        legendOffset: -50,
        legendPosition: "middle",
      }}
      useMesh={true}
      legends={[
        {
          anchor: "top",
          direction: "row",
          justify: false,
          translateX: 0,
          translateY: -25,
          itemsSpacing: 0,
          itemDirection: "left-to-right",
          itemWidth: 120,
          itemHeight: 20,
          itemOpacity: 0.75,
          symbolSize: 12,
          symbolShape: "circle",
          symbolBorderColor: "rgba(0, 0, 0, .5)",
          effects: [
            {
              on: "hover",
              style: {
                itemBackground: "rgba(0, 0, 0, .03)",
                itemOpacity: 1,
              },
            },
          ],
        },
      ]}
    />
  )
}

const Statistics = () => {
  const { projectId } = useParams()
  const { data, loading } = useQuery<ProjectStatisticsDTO>(
    PROJECT_STATISTICS_QUERY,
    {
      variables: {
        id: Number(projectId),
      },
    }
  )

  const project = data?.project!
  const projectConsolidations = data?.projectConsolidations

  const totalLeadTimeMonthRange = projectConsolidations?.map(
    ({ leadTimeRangeMonth }, index) => {
      return {
        x: index,
        y: leadTimeRangeMonth / ONE_DAY_IN_SECONDS,
      }
    }
  )

  const shorterLeadTimeMonth = projectConsolidations?.map(
    ({ leadTimeMinMonth }, index) => {
      return {
        x: index,
        y: leadTimeMinMonth / ONE_DAY_IN_SECONDS,
      }
    }
  )

  const longerLeadTimeMonth = projectConsolidations?.map(
    ({ leadTimeMaxMonth }, index) => {
      return {
        x: index,
        y: leadTimeMaxMonth / ONE_DAY_IN_SECONDS,
      }
    }
  )

  const leadTimeAmplitudeVariationDataGraph = [
    {
      id: "Amplitude Total do Lead Time",
      data: totalLeadTimeMonthRange!,
    },
    {
      id: "Lead Time menor",
      data: shorterLeadTimeMonth!,
    },
    {
      id: "Lead Time maior",
      data: longerLeadTimeMonth!,
    },
  ]

  useEffect(
    () => console.log({ shorterLeadTimeMonth, longerLeadTimeMonth }),
    [data]
  )

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <ProjectPage pageName={"Statistics"} project={project}>
      <Box sx={{ display: "flex", flexWrap: "wrap" }}>
        <GraphBox title={"Variação da Amplitude do Lead Time no Tempo"}>
          <LineGraph
            data={leadTimeAmplitudeVariationDataGraph}
            axisLeftLegend={"Dias"}
          />
        </GraphBox>
      </Box>
    </ProjectPage>
  )
}

export default Statistics
