import { Box, Typography } from "@mui/material"
import Ticket, { TicketProps } from "./Ticket"

type TicketGroupProps = {
  title: string
  // Using it because the responsibility for spacing should be on the parent component
  spaced?: boolean
  data: TicketProps[]
}

const TicketGroup = ({ title, data, spaced = true }: TicketGroupProps) => (
  <Box paddingTop={spaced ? 2 : 0} paddingBottom={spaced ? 6 : 0}>
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
          sx={{ flex: "1 0 21%", mb: spaced ? 4 : 0 }}
        />
      ))}
    </Box>
  </Box>
)

export default TicketGroup
