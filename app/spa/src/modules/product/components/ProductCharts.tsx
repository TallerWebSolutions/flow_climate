import { Typography } from "@mui/material"
import { useTranslation } from "react-i18next"
import { Product } from "../product.types"
import LeadtimeEvolutionChart from "../../charts/components/LeadtimeEvolutionChart"

type ProductChartsProps = {
  product: Product
}

const ProductCharts = ({ product }: ProductChartsProps) => {
  const { t } = useTranslation("products")
  const leadtimeEvolutionData = product.leadtimeEvolutionData
  const xAxis = leadtimeEvolutionData.xAxis
  const yAxisInMonth = leadtimeEvolutionData.yAxisInMonth
  const yAxisInAccumulated = leadtimeEvolutionData.yAxisAccumulated

  return (
    <>
      <Typography component="h4" variant="h4">
        {t("product.charts.title")}
      </Typography>

      <LeadtimeEvolutionChart
        xAxis={xAxis}
        yAxisInPeriod={yAxisInMonth}
        yAxisAccumulated={yAxisInAccumulated}
      />
    </>
  )
}

export default ProductCharts
