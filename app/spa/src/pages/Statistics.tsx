import { gql, useQuery } from "@apollo/client"
import { Backdrop, Box, CircularProgress, Typography } from "@mui/material"
import { ResponsiveLine, Serie } from "@nivo/line"
import { ReactElement } from "react"
import { useParams } from "react-router-dom"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../components/ProjectPage"
import { Project } from "../modules/project/project.types"
import { ProjectConsolidation } from "../modules/project/projectConsolidation.types"

const ONE_DAY_IN_SECONDS = 60 * 60 * 24

export const PROJECT_STATISTICS_QUERY = gql`
  query ProjectStatistics($id: Int!) {
    project(id: $id) {
      ...ProjectStandardFragment

      currentRiskToDeadline
      currentTeamBasedRisk
      remainingDays
      running
    }

    projectConsolidations(projectId: $id, lastDataInWeek: true) {
      leadTimeRangeMonth
      leadTimeMinMonth
      leadTimeMaxMonth
      histogramRange
      leadTimeHistogramBinMin
      leadTimeHistogramBinMax
      interquartileRange
      leadTimeP25
      leadTimeP75
    }
  }
  ${PROJECT_STANDARD_FRAGMENT}
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
          itemWidth: 125,
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

const secondsToDays = (seconds: number) => {
  return (seconds / ONE_DAY_IN_SECONDS).toFixed(2)
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
        y: secondsToDays(leadTimeRangeMonth),
      }
    }
  )

  const shorterLeadTimeMonth = projectConsolidations?.map(
    ({ leadTimeMinMonth }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeMinMonth),
      }
    }
  )

  const longerLeadTimeMonth = projectConsolidations?.map(
    ({ leadTimeMaxMonth }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeMaxMonth),
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

  const amplitudeTotalHistogram = projectConsolidations?.map(
    ({ histogramRange }, index) => {
      return {
        x: index,
        y: secondsToDays(histogramRange),
      }
    }
  )

  const amplitudeBinMinHistogram = projectConsolidations?.map(
    ({ leadTimeHistogramBinMin }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeHistogramBinMin),
      }
    }
  )

  const amplitudeBinMaxHistogram = projectConsolidations?.map(
    ({ leadTimeHistogramBinMax }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeHistogramBinMax),
      }
    }
  )

  const leadTimeAmplitudeHistogramDataGraph = [
    {
      id: "Amplitude Total",
      data: amplitudeTotalHistogram!,
    },
    {
      id: "Bin Min",
      data: amplitudeBinMinHistogram!,
    },
    {
      id: "Bin Max",
      data: amplitudeBinMaxHistogram!,
    },
  ]

  const amplitudeTotalInterquartile = projectConsolidations?.map(
    ({ interquartileRange }, index) => {
      return {
        x: index,
        y: secondsToDays(interquartileRange),
      }
    }
  )

  const amplitudePercentile25Interquartile = projectConsolidations?.map(
    ({ leadTimeP25 }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeP25),
      }
    }
  )

  const amplitudePercentile75Interquartile = projectConsolidations?.map(
    ({ leadTimeP75 }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeP75),
      }
    }
  )

  const leadTimeAmplitudeInterquartileDataGraph = [
    {
      id: "Amplitude Total",
      data: amplitudeTotalInterquartile!,
    },
    {
      id: "Percentil 25",
      data: amplitudePercentile25Interquartile!,
    },
    {
      id: "Percentil 75",
      data: amplitudePercentile75Interquartile!,
    },
  ]

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

        <GraphBox title={"Amplitude do Histograma do Lead Time"}>
          <LineGraph
            data={leadTimeAmplitudeHistogramDataGraph}
            axisLeftLegend={"Frequência"}
          />
        </GraphBox>

        <GraphBox title={"Amplitude do Interquartil do Lead Time"}>
          <LineGraph
            data={leadTimeAmplitudeInterquartileDataGraph}
            axisLeftLegend={"Dias"}
          />
        </GraphBox>
      </Box>
    </ProjectPage>
  )
}

export default Statistics
