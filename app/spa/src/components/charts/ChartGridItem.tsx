import { Grid, Typography, IconButton, Box } from "@mui/material"
import { ReactElement, useRef } from "react"
import DownloadIcon from "@mui/icons-material/Download"
import { exportComponentAsPNG } from "react-component-export-image"

export const ChartGridItem = ({
  children,
  title,
}: {
  children: ReactElement | ReactElement[]
  title: string
}) => {
  const chartRef = useRef<HTMLInputElement>(null)

  return (
    <Grid item p={1} xs={6} ref={chartRef}>
      <Box display="flex" justifyContent="space-between">
        <Typography component="h3" variant="h6">
          {title}
        </Typography>

        <IconButton onClick={() => exportComponentAsPNG(chartRef)}>
          <DownloadIcon />
        </IconButton>
      </Box>
      {children}
    </Grid>
  )
}
