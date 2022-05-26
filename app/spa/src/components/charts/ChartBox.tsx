import { Box, Typography } from "@mui/material"
import { ReactElement } from "react"

export const ChartBox = ({
    children,
    title,
  }: {
    children: ReactElement | ReactElement[]
    title: string
  }) => {
    return (
      <Box>
        <Typography component="h3" variant="h6">
          {title}
        </Typography>
  
        {children}
      </Box>
    )
  }