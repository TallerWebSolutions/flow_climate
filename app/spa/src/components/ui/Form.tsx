import { FormControl, Grid } from "@mui/material"
import { ReactNode } from "react"

export const FormElement = ({ children }: { children: ReactNode }) => (
  <Grid item xs={4}>
    <FormControl sx={{ width: "100%" }}>{children}</FormControl>
  </Grid>
)
