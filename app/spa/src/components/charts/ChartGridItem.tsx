import { Grid, Typography, IconButton, Box, Tooltip } from "@mui/material"
import { ReactElement, useRef } from "react"
import DownloadIcon from "@mui/icons-material/Download"
import { exportComponentAsPNG } from "react-component-export-image"
import InfoIcon from "@mui/icons-material/Info"

export const ChartGridItem = ({
  children,
  title,
  chartTip,
}: {
  children: ReactElement | ReactElement[]
  title: string
  chartTip?: string
}) => {
  const chartRef = useRef<HTMLInputElement>(null)

  return (
    <Grid item p={1} xs={6} ref={chartRef}>
      <Box display="flex" justifyContent="space-between">
        <Typography component="h3" variant="h6">
          {title}

          {chartTip && (
            <Tooltip title={chartTip}>
              <InfoIcon
                color="disabled"
                fontSize="small"
                sx={{ marginLeft: 1 }}
              />
            </Tooltip>
          )}
        </Typography>

        <IconButton onClick={() => exportComponentAsPNG(chartRef)}>
          <DownloadIcon />
        </IconButton>
      </Box>
      {children}
    </Grid>
  )
}
