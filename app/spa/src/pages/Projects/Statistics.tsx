import { gql, useQuery } from "@apollo/client"
import { useParams } from "react-router-dom"
import {
  PROJECT_STANDARD_FRAGMENT,
  ProjectPage,
} from "../../components/Projects/ProjectPage"
import { Project } from "../../modules/project/project.types"
import { ProjectConsolidation } from "../../modules/project/projectConsolidation.types"
import { LineChart } from "../../components/charts/LineChart"
import { ChartGridItem } from "../../components/charts/ChartGridItem"
import { Grid } from "@mui/material"

const ONE_DAY_IN_SECONDS = 60 * 60 * 24

type ProjectStatisticsDTO = {
  project?: Project
  projectConsolidations?: ProjectConsolidation[]
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
        y: secondsToDays(leadTimeRangeMonth || 0),
      }
    }
  )

  const shorterLeadTimeMonth = projectConsolidations?.map(
    ({ leadTimeMinMonth }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeMinMonth || 0),
      }
    }
  )

  const longerLeadTimeMonth = projectConsolidations?.map(
    ({ leadTimeMaxMonth }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeMaxMonth || 0),
      }
    }
  )

  const leadTimeAmplitudeVariationDataGraph = [
    {
      id: "Amplitude Total do Lead Time",
      data: totalLeadTimeMonthRange || [],
    },
    {
      id: "Lead Time menor",
      data: shorterLeadTimeMonth || [],
    },
    {
      id: "Lead Time maior",
      data: longerLeadTimeMonth || [],
    },
  ]

  const amplitudeTotalHistogram = projectConsolidations?.map(
    ({ histogramRange }, index) => {
      return {
        x: index,
        y: secondsToDays(histogramRange || 0),
      }
    }
  )

  const amplitudeBinMinHistogram = projectConsolidations?.map(
    ({ leadTimeHistogramBinMin }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeHistogramBinMin || 0),
      }
    }
  )

  const amplitudeBinMaxHistogram = projectConsolidations?.map(
    ({ leadTimeHistogramBinMax }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeHistogramBinMax || 0),
      }
    }
  )

  const leadTimeAmplitudeHistogramDataGraph = [
    {
      id: "Amplitude Total",
      data: amplitudeTotalHistogram || [],
    },
    {
      id: "Bin Min",
      data: amplitudeBinMinHistogram || [],
    },
    {
      id: "Bin Max",
      data: amplitudeBinMaxHistogram || [],
    },
  ]

  const amplitudeTotalInterquartile = projectConsolidations?.map(
    ({ interquartileRange }, index) => {
      return {
        x: index,
        y: secondsToDays(interquartileRange || 0),
      }
    }
  )

  const amplitudePercentile25Interquartile = projectConsolidations?.map(
    ({ leadTimeP25 }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeP25 || 0),
      }
    }
  )

  const amplitudePercentile75Interquartile = projectConsolidations?.map(
    ({ leadTimeP75 }, index) => {
      return {
        x: index,
        y: secondsToDays(leadTimeP75 || 0),
      }
    }
  )

  const leadTimeAmplitudeInterquartileDataGraph = [
    {
      id: "Amplitude Total",
      data: amplitudeTotalInterquartile || [],
    },
    {
      id: "Percentil 25",
      data: amplitudePercentile25Interquartile || [],
    },
    {
      id: "Percentil 75",
      data: amplitudePercentile75Interquartile || [],
    },
  ]

  return (
    <ProjectPage pageName={"Statistics"} loading={loading}>
      <Grid container spacing={2} rowSpacing={8}>
        <ChartGridItem title={"Variação da Amplitude do Lead Time no Tempo"}>
          <LineChart
            data={leadTimeAmplitudeVariationDataGraph}
            axisLeftLegend={"Dias"}
          />
        </ChartGridItem>

        <ChartGridItem title={"Amplitude do Histograma do Lead Time"}>
          <LineChart
            data={leadTimeAmplitudeHistogramDataGraph}
            axisLeftLegend={"Bins"}
          />
        </ChartGridItem>

        <ChartGridItem title={"Amplitude do Interquartil do Lead Time"}>
          <LineChart
            data={leadTimeAmplitudeInterquartileDataGraph}
            axisLeftLegend={"Dias"}
          />
        </ChartGridItem>
      </Grid>
    </ProjectPage>
  )
}

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
      id
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

export default Statistics
