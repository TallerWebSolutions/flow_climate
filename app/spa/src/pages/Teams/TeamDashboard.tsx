import { gql, useQuery } from "@apollo/client"
import {
  Backdrop,
  Button,
  CircularProgress,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Link,
  Typography,
} from "@mui/material"
import { BarDatum } from "@nivo/bar"
import { SliceTooltipProps } from "@nivo/line"
import { format, subWeeks } from "date-fns"
import { useContext } from "react"
import { useForm } from "react-hook-form"
import SearchIcon from "@mui/icons-material/Search"
import { useTranslation } from "react-i18next"
import { useParams, useSearchParams } from "react-router-dom"
import { BarChart } from "../../components/charts/BarChart"
import { ChartGridItem } from "../../components/charts/ChartGridItem"
import { LineChart, normalizeCfdData } from "../../components/charts/LineChart"
import LineChartTooltip from "../../components/charts/tooltips/LineChartTooltip"

import DateLocale from "../../components/ui/DateLocale"
import { FormElement } from "../../components/ui/Form"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { cfdChartData } from "../../lib/charts"
import { formatDate, secondsToDays, secondsToReadbleDate } from "../../lib/date"
import { Demand } from "../../modules/demand/demand.types"
import TeamBasicPage from "../../modules/team/components/TeamBasicPage"
import { Team } from "../../modules/team/team.types"

const TEAM_DASHBOARD_QUERY = gql`
  query TeamDashboard($teamId: Int!, $startDate: ISO8601Date, $endDate: ISO8601Date) {
    team(id: $teamId) {
      id
      name
      startDate
      endDate
      leadTimeP65
      leadTimeP80
      leadTimeP95
      numberOfDemandsDelivered
      cumulativeFlowChartData(startDate: $startDate, endDate: $endDate) {
        xAxis
        yAxis {
          name
          data
        }
      }
      demandsFlowChartData(startDate: $startDate, endDate: $endDate) {
        creationChartData
        committedChartData
        pullTransactionRate
        throughputChartData
        xAxis
      }
      leadTimeHistogramData(startDate: $startDate, endDate: $endDate) {
        keys
        values
      }
      biggestFiveLeadTimes: latestDeliveries(orderField: "leadtime", sortDirection: DESC, limit: 5) {
        ...demand
      }
      biggestFiveLeadTimesInFourWeeks: latestDeliveries(
        orderField: "leadtime"
        sortDirection: DESC
        limit: 5
        startDate: "${format(subWeeks(new Date(), 4), "yyyy-MM-dd")}"
      ) {
        ...demand
      }
      teamConsolidationsWeekly(startDate: $startDate, endDate: $endDate) {
        leadTimeP80
        consolidationDate
      }
      teamMonthlyInvestment(startDate: $startDate, endDate: $endDate) {
        xAxis
        yAxis
      }
      hoursAndMoneyByEachMember {
        membership {
          memberName
        }
        effortInMonth
        realizedMoneyInMonth
        memberCapacityValue
      }
      teamCapacityHours
    }
  }

  fragment demand on Demand {
    id
    leadtime
    endDate
    product {
      id
      name
    }
    project {
      id
      name
    }
  }
`

type TeamDashboardDTO = {
  team: Team
}

const TeamDashboard = () => {
  const { t } = useTranslation("teams")
  const { teamId, companySlug } = useParams()
  const { me } = useContext(MeContext)
  const [searchParams] = useSearchParams()
  const startDate = searchParams.get("startDate")
  const endDate = searchParams.get("endDate")
  const { data, loading } = useQuery<TeamDashboardDTO>(TEAM_DASHBOARD_QUERY, {
    variables: {
      teamId: Number(teamId),
      ...(startDate && { startDate }),
      ...(endDate && { endDate }),
    },
  })
  const { register } = useForm()

  if (loading)
    return (
      <Backdrop open>
        <CircularProgress color="secondary" />
      </Backdrop>
    )

  const company = me?.currentCompany
  const companyName = company?.name
  const companyUrl = `/companies/${companySlug}`
  const team = data?.team
  const breadcrumbsLinks = [
    { name: companyName || "", url: companyUrl },
    { name: team?.name || "" },
  ]

  const cumulativeFlowChartData = team?.cumulativeFlowChartData
  const cfdXaxis = cumulativeFlowChartData?.xAxis || []
  const cfdYaxis = cumulativeFlowChartData?.yAxis.reverse() || []
  const teamStages = cfdYaxis.map((item) => item.name)
  const teamCumulativeFlowChartData = cfdChartData(
    teamStages,
    cfdXaxis,
    cfdYaxis
  )

  const valuePerMemberColumns = [
    " ",
    t("dashboard.hours"),
    t("dashboard.producedValue"),
    t("dashboard.capacity")
  ]

  let averageHourlyRateMembersCalc = 0
  const valuePerMemberRow = team?.hoursAndMoneyByEachMember.map(
    ({ membership, effortInMonth, realizedMoneyInMonth, memberCapacityValue }) => {
    averageHourlyRateMembersCalc += effortInMonth
    return [
      membership.memberName,
      effortInMonth.toFixed(2),
      realizedMoneyInMonth.toLocaleString('pt-br',{style: 'currency', currency: 'BRL'}),
      memberCapacityValue
    ]
  })

  const averageHourlyRate = 
  mountAverageHourlyRate(averageHourlyRateMembersCalc, team?.hoursAndMoneyByEachMember?.length!) 

  const teamInfoRows = team
    ? [
      [t("dashboard.name"), team.name],
      [
        t("dashboard.startDate"),
        team.startDate ? <DateLocale date={team.startDate} /> : "",
      ],
      [
        t("dashboard.endDate"),
        team.endDate ? <DateLocale date={team.endDate} /> : "",
      ],
      [t("dashboard.delivered"), team.numberOfDemandsDelivered || 0],
      [
        t("dashboard.leadTimeP65"),
        `${secondsToDays(team.leadTimeP65 || 0)} ${t("dashboard.days")}`,
      ],
      [
        t("dashboard.leadTimeP80"),
        `${secondsToDays(team.leadTimeP80 || 0)} ${t("dashboard.days")}`,
      ],
      [
        t("dashboard.leadTimeP95"),
        `${secondsToDays(team.leadTimeP95 || 0)} ${t("dashboard.days")}`,
      ],
      [
        t("dashboard.capacityOfHours"),
        `${team.teamCapacityHours}h` 
      ]
    ]
    : []

  const biggestFiveLeadTimesRows = deliveriesRows(
    team?.biggestFiveLeadTimes,
    companyUrl
  )
  const biggestFiveLeadTimesInFourWeeksRows = deliveriesRows(
    team?.biggestFiveLeadTimesInFourWeeks,
    companyUrl
  )

  const demandsFlowChartData = team?.demandsFlowChartData
  const committedChartData = demandsFlowChartData?.committedChartData
  const teamFlowChartData: BarDatum[] = committedChartData
    ? committedChartData?.map((_, index) => {
      const creationChartData = demandsFlowChartData.creationChartData || []

      const pullTransactionRate =
        demandsFlowChartData.pullTransactionRate || []

      const throughputChartData =
        demandsFlowChartData.throughputChartData || []

      return {
        index: demandsFlowChartData.xAxis?.[index] || index,
        [t("charts.flow_data_created")]: creationChartData[index],
        [t("charts.flow_data_committed_to")]: committedChartData[index],
        [t("charts.flow_data_pull_transactions")]: pullTransactionRate[index],
        [t("charts.flow_data_delivered")]: throughputChartData[index],
      }
    })
    : []

  const leadTimeHistogramData = team?.leadTimeHistogramData
  const teamLeadTimeHistogramData: BarDatum[] = leadTimeHistogramData
    ? leadTimeHistogramData.keys.map((el, index) => {
      const projectLeadTimeHistogramDataKeysInDays =
        secondsToDays(el).toFixed(2)

      return {
        index,
        [t("charts.lead_time_histogram_chart_x_label")]:
          projectLeadTimeHistogramDataKeysInDays,
        [t("charts.lead_time_histogram_chart_y_label")]:
          leadTimeHistogramData.values[index],
      }
    })
    : []

  const teamConsolidationsWeekly = team?.teamConsolidationsWeekly
  const leadTimeP80ChartData = [
    {
      id: team?.name || "",
      data:
        teamConsolidationsWeekly?.map(({ leadTimeP80, consolidationDate }) => {
          const leadTimep80InDays = secondsToDays(leadTimeP80)

          return {
            x: consolidationDate,
            y: leadTimep80InDays,
          }
        }) || [],
    },
  ]

  const teamMonthlyInvestment = team?.teamMonthlyInvestment
  const financialPerformanceChartData =
    normalizeFinancialPerformanceData(team?.name!, teamMonthlyInvestment?.xAxis!, teamMonthlyInvestment?.yAxis!)

  return (
    <TeamBasicPage
      breadcrumbsLinks={breadcrumbsLinks}
      loading={loading}
      title={team?.name}
    >
      <Grid container columnSpacing={4} marginBottom={4}>
        <Grid item xs={4}>
          <Table title={t("dashboard.infoTable")} rows={teamInfoRows} />
        </Grid>
        <Grid item xs={4}>
          <Table
            title={t("dashboard.biggestFiveLeadTimes")}
            rows={biggestFiveLeadTimesRows}
          />
        </Grid>
        <Grid item xs={4}>
          <Table
            title={t("dashboard.biggestFiveLeadTimesInFourWeeks")}
            rows={biggestFiveLeadTimesInFourWeeksRows}
          />
        </Grid>
      </Grid>
      <Grid>
        <Table 
          title={`${t("dashboard.averageValueOfHours")} - ${averageHourlyRate}`} 
          headerCells={valuePerMemberColumns} 
          rows={valuePerMemberRow!} 
        />
      </Grid>
      <Typography component="h2" variant="h5" marginBottom={4}>
        {t("charts.title")}
      </Typography>
      <form>
        <FormGroup>
          <Grid container spacing={5} marginBottom={4}>
            <FormElement>
              <InputLabel shrink htmlFor="startDate">
                {t("dashboard.startDate")}
              </InputLabel>
              <Input
                {...register("startDate")}
                type="date"
                defaultValue={searchParams.get("startDate")}
              />
            </FormElement>
            <FormElement>
              <InputLabel shrink htmlFor="endDate">
                {t("dashboard.endDate")}
              </InputLabel>
              <Input
                {...register("endDate")}
                type="date"
                defaultValue={searchParams.get("endDate")}
              />
            </FormElement>
            <FormElement>
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                <SearchIcon fontSize="large" color="primary" />
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
      <Grid container columnSpacing={4}>
        {teamCumulativeFlowChartData && (
          <ChartGridItem
            title={t("charts.cumulativeFlowChart", {
              teamName: team?.name,
            })}
          >
            <LineChart
              data={normalizeCfdData(teamCumulativeFlowChartData)}
              axisLeftLegend={t("charts.cumulativeFlowYLabel")}
              props={{
                yScale: {
                  type: "linear",
                  stacked: true,
                },
                areaOpacity: 1,
                enableArea: true,
                enableSlices: "x",
                sliceTooltip: ({ slice }: SliceTooltipProps) => (
                  <LineChartTooltip slice={slice} />
                ),
                margin: { left: 80, right: 20, top: 25, bottom: 65 },
                axisBottom: {
                  tickSize: 5,
                  tickPadding: 5,
                  legendPosition: "middle",
                  legendOffset: 60,
                  tickRotation: -40,
                },
              }}
            />
          </ChartGridItem>
        )}
        <ChartGridItem title={t("charts.flowDataChart")}>
          <BarChart
            data={teamFlowChartData}
            keys={[
              t("charts.flowDataCreated"),
              t("charts.flowDataCommitted_to"),
              t("charts.flowDataPullTransactions"),
              t("charts.flowDataDelivered"),
            ]}
            indexBy="index"
            axisLeftLegend={t("charts.flowDataYLabel")}
            axisBottomLegend={t("charts.flowDataXLabel")}
            groupMode="grouped"
          />
        </ChartGridItem>
        <ChartGridItem title={t("charts.leadTimeHistogramChart")}>
          <BarChart
            data={teamLeadTimeHistogramData}
            keys={[t("charts.leadTimeHistogramChartHits")]}
            indexBy={t("charts.leadTimeHistogramChartXLabel")}
            axisLeftLegend={t("charts.leadTimeHistogramChartYLabel")}
            axisBottomLegend={t("charts.leadTimeHistogramChartXLabel")}
            padding={0}
          />
        </ChartGridItem>
        <ChartGridItem title={t("charts.leadTimeP80Chart")}>
          <LineChart
            data={leadTimeP80ChartData}
            axisLeftLegend={t("charts.leadTimeP80YLabel")}
            props={{
              enableSlices: "x",
              sliceTooltip: ({ slice }: SliceTooltipProps) => (
                <LineChartTooltip slice={slice} />
              ),
            }}
          />
        </ChartGridItem>
        <ChartGridItem title={t("charts.financialPerformance")}>
          <LineChart
            data={financialPerformanceChartData}
            axisLeftLegend={t("charts.financialPerformanceYLabel")}
            props={{
              enableSlices: "x",
              sliceTooltip: ({ slice }: SliceTooltipProps) => (
                <LineChartTooltip slice={slice} />
              ),
            }}
          />
        </ChartGridItem>
      </Grid>
    </TeamBasicPage>
  )
}

export default TeamDashboard

const deliveriesRows = (demands: Demand[] = [], companyUrl: string) =>
  demands.map((demand) => {
    return [
      <Link
        href={`${companyUrl}/demands/${demand.externalId}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.externalId}
      </Link>,
      <Link
        href={`${companyUrl}/projects/${demand.project?.id}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.project?.name}
      </Link>,
      <Link
        href={`${companyUrl}/products/${demand.product?.id}`}
        sx={{ color: "info.dark", textDecoration: "none" }}
      >
        {demand.product?.name}
      </Link>,
      demand.endDate
        ? formatDate({
          date: demand.endDate,
          format: "dd/MM/yyyy' 'HH:mm:ss",
        })
        : "",
      secondsToReadbleDate(demand.leadtime),
      demand.demandBlocksCount,
    ]
  })

const normalizeFinancialPerformanceData = (teamName: string, xAxisData: string[], yAxisData: number[]) => {
  const financialPerformanceData = xAxisData.map((item: string, idx: number) => {
    return {
      xAxis: item,
      yAxis: yAxisData[idx]
    }
  })

  return [{
    id: teamName || "",
    data: mountFinancialPerformanceChartData(financialPerformanceData)
  }]
}

const mountFinancialPerformanceChartData = (data: Array<{
  xAxis: string
  yAxis: number
}>) => {
  return data?.map(({ xAxis, yAxis }) => {
    return {
      x: xAxis,
      y: yAxis
    }
  }) || []
}

const mountAverageHourlyRate = (average: number, length: number) => {
  if (average === 0 || length === 0) {
    return 0
  }

  return (average / length).toFixed()
}