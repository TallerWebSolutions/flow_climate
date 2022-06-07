import { Grid, Typography } from "@mui/material"
import { ReactElement } from "react"

export const ChartGridItem = ({
  children,
  title,
}: {
  children: ReactElement | ReactElement[]
  title: string
}) => {
  return (
    <Grid item p={1} xs={6}>
      <Typography component="h3" variant="h6">
        {title}
      </Typography>

      {children}
    </Grid>
  )
}
