import { Box } from "@mui/material"
import { ResponsivePieCanvas } from "@nivo/pie"
import { SimpleChartData } from "../../modules/charts/charts.types"

type PieChartProps = {
  data: SimpleChartData[]
}

const pieDataToDatum = (data: SimpleChartData[]) =>
  data.map((item) => ({ id: item.label, value: item.value }))

const PieChart = ({ data }: PieChartProps) => (
  <Box height={420}>
    <ResponsivePieCanvas
      data={pieDataToDatum(data)}
      colors={{ scheme: "category10" }}
      innerRadius={0.1}
      padAngle={0.9}
      margin={{ top: 10, bottom: 10 }}
    />
  </Box>
)

export default PieChart
