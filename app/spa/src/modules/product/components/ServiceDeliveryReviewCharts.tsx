import { Grid } from "@mui/material"
import { useTranslation } from "react-i18next"

import PieChart from "../../../components/charts/PieChart"
import { FlowEvent } from "../../flowEvent/flowEvent.types"
import { ChartGridItem } from "../../../components/charts/ChartGridItem"

type ServiceDeliveryReviewChartsProps = {
  flowEvents: FlowEvent[]
}

const ServiceDeliveryReviewCharts = ({
  flowEvents,
}: ServiceDeliveryReviewChartsProps) => {
  const { t } = useTranslation("serviceDeliveryReview")

  const flowEventTypes = new Set(flowEvents?.map((event) => event.eventType))
  const flowEventsData = Array.from(flowEventTypes).map((eventType) => ({
    label: eventType,
    value: flowEvents.filter((event) => event.eventType === eventType).length,
  }))

  return (
    <Grid container>
      <ChartGridItem title={t("charts.flowEvents.title")} columns={12}>
        <PieChart data={flowEventsData} />
      </ChartGridItem>
    </Grid>
  )
}

export default ServiceDeliveryReviewCharts