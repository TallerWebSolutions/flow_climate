import { gql, useQuery } from "@apollo/client"
import { Box, Typography } from "@mui/material"
import { ReactElement } from "react"
import { useParams } from "react-router-dom"
import { LineChart } from "../../components/charts/LineChart"
import {
  ProjectPage,
  PROJECT_STANDARD_FRAGMENT,
} from "../../components/ProjectPage"
import { Project } from "../../modules/project/project.types"
import { ProjectConsolidation } from "../../modules/project/projectConsolidation.types"

const ONE_DAY_IN_SECONDS = 60 * 60 * 24

// @TODO: projectConsolidations should exist inside project field.
export const PROJECT_STATISTICS_QUERY = gql`
  query ProjectStatistics($id: ID!) {
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
        padding: 2,
        my: 5,
      }}
    >
      <Typography component="h3" variant="h6" my={2}>
        {title}
      </Typography>
      <Box sx={{ width: "100%" }}>{children}</Box>
    </Box>
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

  return (
    <ProjectPage pageName={"Statistics"} loading={loading}>
      <Box sx={{ display: "flex", flexWrap: "wrap" }}>
        <GraphBox title={"Variação da Amplitude do Lead Time no Tempo"}>
          <LineChart
            data={leadTimeAmplitudeVariationDataGraph}
            axisLeftLegend={"Dias"}
          />
        </GraphBox>

        <GraphBox title={"Amplitude do Histograma do Lead Time"}>
          <LineChart
            data={leadTimeAmplitudeHistogramDataGraph}
            axisLeftLegend={"Bins"}
          />
        </GraphBox>

        <GraphBox title={"Amplitude do Interquartil do Lead Time"}>
          <LineChart
            data={leadTimeAmplitudeInterquartileDataGraph}
            axisLeftLegend={"Dias"}
          />
        </GraphBox>
      </Box>
    </ProjectPage>
  )
}

export default Statistics
