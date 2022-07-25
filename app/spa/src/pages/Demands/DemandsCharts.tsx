import { secondsToDays } from "../../lib/date"
import { gql, useQuery } from "@apollo/client"
import { Backdrop, CircularProgress, Grid } from "@mui/material"
import { ChartGridItem } from "../../components/charts/ChartGridItem"
import { ScatterChart } from "../../components/charts/ScatterChart"
import { useTranslation } from "react-i18next"
import { useContext, useState } from "react"
import { MeContext } from "../../contexts/MeContext"
import { FieldValues } from "react-hook-form"
import DemandsPage, { DemandsSearchDTO } from "../../components/DemandsPage"
import { useSearchParams } from "react-router-dom"
import { BarChart } from "../../components/charts/BarChart"
import { BarDatum } from "@nivo/bar"

const DEMANDS_CHART_QUERY = gql`
  query DemandsSearch(
    $orderField: String!
    $searchText: String
    $pageNumber: Int
    $perPage: Int
    $project: ID
    $startDate: ISO8601Date
    $endDate: ISO8601Date
    $demandStatus: DemandStatuses
    $initiative: ID
    $team: ID
    $sortDirection: SortDirection
  ) {
    demandsTableData: demandsList(
      searchOptions: {
        pageNumber: $pageNumber
        perPage: $perPage
        projectId: $project
        startDate: $startDate
        endDate: $endDate
        demandStatus: $demandStatus
        iniciativeId: $initiative
        teamId: $team
        searchText: $searchText
        orderField: $orderField
        sortDirection: $sortDirection
      }
    ) {
      controlChart {
        leadTimeP65
        leadTimeP80
        leadTimeP95

        leadTimes
        xAxis
      }
      leadTimeBreakdown {
        xAxis
        yAxis
      }
      flowData {
        creationChartData
        committedChartData
        pullTransactionRate
        throughputChartData
        xAxis
      }
    }
  }
`

const DemandsCharts = () => {
  const { me } = useContext(MeContext)
  const { t } = useTranslation(["demands"])
  const [searchParams] = useSearchParams()

  const [filters, setFilters] = useState<FieldValues>({
    initiative: searchParams.get("initiative"),
    team: searchParams.get("team"),
    project: searchParams.get("project"),
    searchText: searchParams.get("searchText"),
    demandStatus: searchParams.get("demandStatus"),
    sortDirection: "DESC",
    orderField: "end_date",
    startDate: searchParams.get("startDate"),
    endDate: searchParams.get("endDate"),
  })

  const breadcrumbsLinks = [
    {
      name: me?.currentCompany?.name || "",
      url: `/companies/${me?.currentCompany?.slug}`,
    },
    {
      name: t("list.title"),
    },
  ]

  const { data, loading } = useQuery<DemandsSearchDTO>(DEMANDS_CHART_QUERY, {
    variables: Object.keys(filters)
      .filter((key) => {
        return filters[key]?.length > 0
      })
      .reduce<Record<string, string>>((acc, el) => {
        return { ...acc, [el]: filters[el] }
      }, {}),
  })

  const demandsLeadTimeBreakdownData = data?.demandsTableData.leadTimeBreakdown
  const demandsLeadTimeBreakdown = demandsLeadTimeBreakdownData
    ? demandsLeadTimeBreakdownData.xAxis.map((xValue, index: number) => {
        return {
          index: xValue,
          [xValue]: demandsLeadTimeBreakdownData.yAxis[index].toFixed(2),
        }
      })
    : []

  const demandsFlowChartData = data?.demandsTableData.flowData
  const committedChartData = demandsFlowChartData?.committedChartData
  const flowChartData: BarDatum[] = committedChartData
    ? committedChartData?.map((_, index) => {
        const creationChartData = demandsFlowChartData.creationChartData
          ? demandsFlowChartData.creationChartData
          : []

        const pullTransactionRate = demandsFlowChartData.pullTransactionRate
          ? demandsFlowChartData.pullTransactionRate
          : []

        const throughputChartData = demandsFlowChartData.throughputChartData
          ? demandsFlowChartData.throughputChartData
          : []

        return {
          index: demandsFlowChartData.xAxis?.[index] || index,
          [t("charts_tab.project_charts.flow_data_created")]:
            creationChartData[index],
          [t("charts_tab.project_charts.flow_data_committed_to")]:
            committedChartData[index],
          [t("charts_tab.project_charts.flow_data_pull_transactions")]:
            pullTransactionRate[index],
          [t("charts_tab.project_charts.flow_data_delivered")]:
            throughputChartData[index],
        }
      })
    : []

  const controlChart = data?.demandsTableData.controlChart
  const controlChartXAxis = controlChart?.xAxis || []
  const demandsLeadTime =
    controlChart?.leadTimes.map((leadTime) =>
      secondsToDays(Number(leadTime))
    ) || []
  const leadTimeP95InDays = secondsToDays(Number(controlChart?.leadTimeP95))
  const leadTimeP80InDays = secondsToDays(Number(controlChart?.leadTimeP80))
  const leadTimeP65InDays = secondsToDays(Number(controlChart?.leadTimeP65))

  const controlChartData = {
    xAxis: controlChartXAxis,
    yAxis: demandsLeadTime,
    leadTimeP65: leadTimeP65InDays,
    leadTimeP80: leadTimeP80InDays,
    leadTimeP95: leadTimeP95InDays,
  }

  const leadTimeControlP95Marker = {
    value: leadTimeP95InDays,
    legend: t("demandsCharts.leadTimeControlMarkerP95", {
      days: leadTimeP95InDays,
    }),
  }

  const leadTimeControlP80Marker = {
    value: leadTimeP80InDays,
    legend: t("demandsCharts.leadTimeControlMarkerP80", {
      days: leadTimeP80InDays,
    }),
  }

  const leadTimeControlP65Marker = {
    value: leadTimeP65InDays,
    legend: t("demandsCharts.leadTimeControlMarkerP65", {
      days: leadTimeP65InDays,
    }),
  }

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  return (
    <DemandsPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
      filters={filters}
      setFilters={setFilters}
    >
      <Grid container spacing={2} rowSpacing={8} sx={{ marginTop: 4 }}>
        <ChartGridItem title={t("demandsCharts.leadTimeControlChart")}>
          <ScatterChart
            data={controlChartData}
            markers={[
              leadTimeControlP65Marker,
              leadTimeControlP80Marker,
              leadTimeControlP95Marker,
            ]}
          />
        </ChartGridItem>

        <ChartGridItem title={t("charts.leadTimeBreakdown.title")}>
          <BarChart
            data={demandsLeadTimeBreakdown}
            keys={demandsLeadTimeBreakdownData?.xAxis.map(String) || []}
            showLegends={false}
            indexBy="index"
            axisLeftLegend={t("charts.leadTimeBreakdown.yLabel")}
          />
        </ChartGridItem>

        <ChartGridItem title={t("charts_tab.project_charts.flow_data_chart")}>
          <BarChart
            data={flowChartData}
            keys={[
              t("charts_tab.project_charts.flow_data_created"),
              t("charts_tab.project_charts.flow_data_committed_to"),
              t("charts_tab.project_charts.flow_data_pull_transactions"),
              t("charts_tab.project_charts.flow_data_delivered"),
            ]}
            indexBy="index"
            axisLeftLegend={t("charts_tab.project_charts.flow_data_y_label")}
            axisBottomLegend={t("charts_tab.project_charts.flow_data_x_label")}
            groupMode="grouped"
          />
        </ChartGridItem>
      </Grid>
    </DemandsPage>
  )
}

export default DemandsCharts
