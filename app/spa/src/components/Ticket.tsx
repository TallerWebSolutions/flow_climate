import { Box, SxProps, Typography } from "@mui/material"
import { Dinero } from "dinero.js"

export type TicketProps = {
  title: string
  value?: string | number | Dinero<number>
  unity?: string
  sx?: SxProps
}

const Ticket = ({ title, value, unity, sx }: TicketProps) => (
  <Box paddingX={2} borderLeft="4px solid" borderColor="primary.light" sx={sx}>
    <Typography fontSize="1rem" color="primary.dark">
      {title}
    </Typography>
    <Box
      sx={{
        display: "flex",
        alignItems: "flex-end",
      }}
    >
      <Typography fontSize="2.125rem" color="grey.600" lineHeight={1}>
        {value}
      </Typography>
      <Typography color="grey.600" pl={1} fontWeight={400}>
        {unity}
      </Typography>
    </Box>
  </Box>
)

export default Ticket
