import { Grid, Box, Typography } from "@mui/material"
import { LineGraphProps, LineChart } from "./LineChart"

type ChartLineboxProps = {
  title: string
} & LineGraphProps

const ChartLineBox = ({
  title,
  data,
  axisLeftLegend,
  props,
}: ChartLineboxProps) => {
  return (
    <Grid item xs={6} sx={{ padding: 1 }}>
      <Box sx={{ height: "350px" }}>
        <Typography>{title}</Typography>

        <LineChart data={data} axisLeftLegend={axisLeftLegend} props={props} />
      </Box>
    </Grid>
  )
}

export default ChartLineBox
