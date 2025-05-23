import { secondsToDays } from "../../lib/date"
import { gql, useQuery } from "@apollo/client"
import { Grid } from "@mui/material"
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
import { LineChart } from "../../components/charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../components/charts/tooltips/LineChartTooltip"

const DEMANDS_CHART_QUERY = gql`
  query DemandsSearchCharts(
    $orderField: String!
    $searchText: String
    $pageNumber: Int
    $perPage: Int
    $project: ID
    $product: ID
    $startDate: ISO8601Date
    $endDate: ISO8601Date
    $demandStatus: DemandStatuses
    $team: ID
    $sortDirection: SortDirection
    $demandType: String
  ) {
    demandsTableData: demandsList(
      searchOptions: {
        pageNumber: $pageNumber
        perPage: $perPage
        projectId: $project
        productId: $product
        startDate: $startDate
        endDate: $endDate
        demandStatus: $demandStatus
        teamId: $team
        searchText: $searchText
        orderField: $orderField
        sortDirection: $sortDirection
        demandType: $demandType
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
      flowEfficiency {
        xAxis
        yAxis
      }
      leadTimeEvolutionP80 {
        xAxis
        yAxis
      }
    }
  }
`

const DemandsCharts = () => {
  const { me } = useContext(MeContext)
  const { t } = useTranslation(["demand"])
  const [searchParams] = useSearchParams()

  const [filters, setFilters] = useState<FieldValues>({
    team: searchParams.get("team"),
    project: searchParams.get("project"),
    searchText: searchParams.get("searchText"),
    demandStatus: searchParams.get("demandStatus"),
    sortDirection: "DESC",
    orderField: "end_date",
    startDate: searchParams.get("startDate"),
    endDate: searchParams.get("endDate"),
    demandType: searchParams.get("demandType"),
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
          [t("charts.flowData.created")]: creationChartData[index],
          [t("charts.flowData.committed")]: committedChartData[index],
          [t("charts.flowData.pulled")]: pullTransactionRate[index],
          [t("charts.flowData.delivered")]: throughputChartData[index],
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

  const flowEfficiencyChartData = data?.demandsTableData.flowEfficiency
  const flowEfficiencyChart = flowEfficiencyChartData
    ? [
        {
          id: t("charts.flowEfficiency.title"),
          data: flowEfficiencyChartData.xAxis.map((xValue, index: number) => {
            return {
              x: xValue,
              y: flowEfficiencyChartData.yAxis[index].toFixed(2),
            }
          }),
        },
      ]
    : []

  const leadTimeEvolutionP80ChartData =
    data?.demandsTableData.leadTimeEvolutionP80
  const leadTimeEvolutionP80Chart = leadTimeEvolutionP80ChartData
    ? [
        {
          id: t("charts.leadTimeEvolutionP80.title"),
          data: leadTimeEvolutionP80ChartData.xAxis.map(
            (xValue, index: number) => {
              return {
                x: xValue,
                y: secondsToDays(
                  leadTimeEvolutionP80ChartData.yAxis[index]
                ).toFixed(2),
              }
            }
          ),
        },
      ]
    : []

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

        <ChartGridItem
          title={t("charts.flowData.title")}
          chartTip={t("charts.shared.eightWeeksChart.chartTip")}
        >
          <BarChart
            data={flowChartData}
            keys={[
              t("charts.flowData.created"),
              t("charts.flowData.committed"),
              t("charts.flowData.pulled"),
              t("charts.flowData.delivered"),
            ]}
            indexBy="index"
            axisLeftLegend={t("charts.flowData.yLabel")}
            axisBottomLegend={t("charts.flowData.xLabel")}
            groupMode="grouped"
          />
        </ChartGridItem>

        <ChartGridItem
          title={t("charts.flowEfficiency.title")}
          chartTip={t("charts.shared.eightWeeksChart.chartTip")}
        >
          <LineChart
            data={flowEfficiencyChart}
            axisLeftLegend={"%"}
            props={{
              margin: { left: 80, right: 20, top: 25, bottom: 65 },
              axisBottom: {
                tickSize: 5,
                tickPadding: 5,
                legendPosition: "middle",
                legendOffset: 60,
                tickRotation: -40,
              },
              enableSlices: "x",
              sliceTooltip: ({ slice }: SliceTooltipProps) => (
                <LineChartTooltip
                  slice={slice}
                  xLabel={t("charts.flowEfficiency.xLabel")}
                />
              ),
            }}
          />
        </ChartGridItem>

        <ChartGridItem
          title={t("charts.leadTimeEvolutionP80.title")}
          chartTip={t("charts.shared.eightWeeksChart.chartTip")}
        >
          <LineChart
            data={leadTimeEvolutionP80Chart}
            axisLeftLegend={t("charts.leadTimeEvolutionP80.yLabel")}
            props={{
              margin: { left: 80, right: 20, top: 25, bottom: 65 },
              axisBottom: {
                tickSize: 5,
                tickPadding: 5,
                legendPosition: "middle",
                legendOffset: 60,
                tickRotation: -40,
              },

              enableSlices: "x",
              sliceTooltip: ({ slice }: SliceTooltipProps) => (
                <LineChartTooltip
                  slice={slice}
                  xLabel={t("charts.leadTimeEvolutionP80.xLabel")}
                />
              ),
            }}
          />
        </ChartGridItem>
      </Grid>
    </DemandsPage>
  )
}

export default DemandsCharts
