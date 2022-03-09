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
    <Box
      sx={{ display: "flex", flexWrap: "wrap", justifyContent: "space-around" }}
    >
      {data.map((item, key) => (
        <Ticket
          key={`${key}-${item.title}`}
          {...item}
          sx={{ flex: "1 0 21%", mb: 4 }}
        />
      ))}
    </Box>
  </Box>
)

export default TicketGroup
