import { Box, SxProps, Typography } from "@mui/material"

export type TicketProps = {
  title: string
  value?: string | number
  sx?: SxProps
}

const Ticket = ({ title, value, sx }: TicketProps) => (
  <Box paddingX={2} borderLeft="4px solid" borderColor="primary.light" sx={sx}>
    <Typography fontSize="1rem" color="primary.dark">
      {title}
    </Typography>
    <Typography fontSize="2.125rem" color="grey.600" lineHeight={1}>
      {value}
    </Typography>
  </Box>
)

export default Ticket
