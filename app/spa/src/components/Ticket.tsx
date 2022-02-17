import { Box, Typography } from "@mui/material"

type TicketProps = {
  title: string
  value?: string | number
}

const Ticket = ({ title, value }: TicketProps) => (
  <Box paddingX={2} borderLeft="4px solid" borderColor="primary.light">
    <Typography fontSize="1rem" color="primary.dark">
      {title}
    </Typography>
    <Typography fontSize="2.125rem" color="grey.600" lineHeight={1}>
      {value}
    </Typography>
  </Box>
)

export default Ticket
