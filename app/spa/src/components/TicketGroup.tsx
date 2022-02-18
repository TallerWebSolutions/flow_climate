import { Box, Typography } from "@mui/material"
import Ticket, { TicketProps } from "./Ticket"

type TicketGroupProps = {
  title: string
  data: TicketProps[]
}

const TicketGroup = ({ title, data }: TicketGroupProps) => (
  <Box paddingTop={2} paddingBottom={6}>
    <Typography component="h2" variant="h5" mb={3}>
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
  </Box>
)

export default TicketGroup
