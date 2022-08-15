import { Box } from "@mui/material"
import { ResponsivePieCanvas } from "@nivo/pie"

type PieChartProps = {
  // @see https://github.com/plouc/nivo/issues/197#issuecomment-1215065645
  data: unknown[]
}

const PieChart = ({ data }: PieChartProps) => (
  <Box height={420}>
    <ResponsivePieCanvas
      data={data}
      colors={{ scheme: "category10" }}
      innerRadius={0.1}
      padAngle={0.7}
    />
  </Box>
)

export default PieChart
