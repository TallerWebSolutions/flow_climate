import { Grid } from "@mui/material"
import { useTranslation } from "react-i18next"

import PieChart from "../../../components/charts/PieChart"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"
import { SimpleChartData } from "../../charts/charts.types"

type ServiceDeliveryReviewChartsProps = {
  flowEventsChartData?: SimpleChartData[]
  classOfServiceChartData?: SimpleChartData[]
}

const ServiceDeliveryReviewCharts = ({
  flowEventsChartData,
  classOfServiceChartData,
}: ServiceDeliveryReviewChartsProps) => {
  const { t } = useTranslation("serviceDeliveryReview")

  return (
    <Grid container spacing={4}>
      {!!flowEventsChartData?.length && (
        <ChartGridItem title={t("charts.flowEvents.title")} columns={6}>
          <PieChart data={flowEventsChartData} />
        </ChartGridItem>
      )}
      {!!classOfServiceChartData?.length && (
        <ChartGridItem
          title={t("charts.classOfServiceChartData.title")}
          columns={6}
        >
          <PieChart data={classOfServiceChartData} />
        </ChartGridItem>
      )}
    </Grid>
  )
}

export default ServiceDeliveryReviewCharts
