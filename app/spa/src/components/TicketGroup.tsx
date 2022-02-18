import { Box, Typography } from "@mui/material"
import { Fragment } from "react"
import Ticket, { TicketProps } from "./Ticket"

type TicketGroupProps = {
  title: string
  data: TicketProps[]
}

const TicketGroup = ({ title, data }: TicketGroupProps) => (
  <Fragment>
    <Typography component="h2" variant="h6" mb={3}>
      {title}
    </Typography>
    <Box sx={{ display: "flex" }}>
      {data.map((item) => (
        <Ticket
          title={item.title}
          value={item.value}
          sx={{ flexGrow: 1, flexBasis: 1 }}
        />
      ))}
    </Box>
  </Fragment>
)

export default TicketGroup
