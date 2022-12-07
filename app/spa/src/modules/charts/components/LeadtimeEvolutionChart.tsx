import { Typography } from "@mui/material"
import { LineChart } from "../../../components/charts/LineChart"
import { SliceTooltipProps } from "@nivo/line"
import LineChartTooltip from "../../../components/charts/tooltips/LineChartTooltip"
import { useTranslation } from "react-i18next"

type LeadtimeEvolutionChartProps = {
  xAxis: string[]
  yAxisInPeriod: number[]
  yAxisAccumulated: number[]
}

const LeadtimeEvolutionChart = ({
  xAxis,
  yAxisInPeriod,
  yAxisAccumulated,
}: LeadtimeEvolutionChartProps) => {
  const { t } = useTranslation("products")

  const productLeadtimeEvolution = [
    {
      id: t("product.charts.leadtimeEvolutionInTime.accumulated"),
      data:
        yAxisAccumulated.map((leadtimeAcc, index) => ({
          x: xAxis[index],
          y: leadtimeAcc.toFixed(2),
        })) || [],
    },
    {
      id: t("product.charts.leadtimeEvolutionInTime.inMonth"),
      data:
        yAxisInPeriod.map((leadtimeInMonth, index) => ({
          x: xAxis[index],
          y: leadtimeInMonth.toFixed(2),
        })) || [],
    },
  ]

  return (
    <>
      <Typography component="h5" variant="h5" align={"center"}>
        {t("product.charts.leadtimeEvolutionInTime.title")}
      </Typography>

      <LineChart
        data={productLeadtimeEvolution}
        axisLeftLegend={t(
          "product.charts.leadtimeEvolutionInTime.axisLeftLegend"
        )}
        props={{
          margin: { left: 80, right: 20, top: 25, bottom: 65 },
          axisBottom: {
            tickSize: 5,
            tickPadding: 5,
            legendPosition: "middle",
            legendOffset: 60,
            tickRotation: -40,
          },
          yFormat: "=.2",
          enableSlices: "x",
          sliceTooltip: ({ slice }: SliceTooltipProps) => (
            <LineChartTooltip
              slice={slice}
              xLabel={t("product.charts.leadtimeEvolutionInTime.title")}
            />
          ),
        }}
      />
    </>
  )
}

export default LeadtimeEvolutionChart
