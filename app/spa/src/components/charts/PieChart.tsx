import { Box } from "@mui/material"
import { ResponsivePieCanvas } from "@nivo/pie"

export type PieChartData = {
  label: string
  value: number
}

type PieChartProps = {
  // @see https://github.com/plouc/nivo/issues/197#issuecomment-1215065645
  data: PieChartData[]
}

const pieDataToDatum = (data: PieChartData[]) =>
  data.map((item) => ({ id: item.label, value: item.value }))

const PieChart = ({ data }: PieChartProps) => (
  <Box height={420}>
    <ResponsivePieCanvas
      data={pieDataToDatum(data)}
      colors={{ scheme: "category10" }}
      innerRadius={0.1}
      padAngle={0.7}
    />
  </Box>
)

export default PieChart
