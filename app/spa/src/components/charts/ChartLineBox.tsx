import { useRef } from "react"
import { Grid, Box, Typography, IconButton } from "@mui/material"
import { exportComponentAsPNG } from "react-component-export-image"
import DownloadIcon from "@mui/icons-material/Download"

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
  const chartRef = useRef<HTMLInputElement>(null)
  return (
    <Grid item xs={6} sx={{ padding: 1, position: "relative" }}>
      <IconButton
        onClick={() => exportComponentAsPNG(chartRef)}
        sx={{ position: "absolute", top: "1rem", right: "1rem", zIndex: 1 }}
      >
        <DownloadIcon />
      </IconButton>
      <Box sx={{ height: "350px", position: "relative" }} ref={chartRef}>
        <Typography>{title}</Typography>

        <LineChart data={data} axisLeftLegend={axisLeftLegend} props={props} />
      </Box>
    </Grid>
  )
}

export default ChartLineBox
