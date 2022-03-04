import { Box, SxProps, Typography } from "@mui/material"

const MAX_ARRAY_SIZE = 10

export type TicketProps = {
  title: string
  value?: string | number | number[]
  unity?: string
  sx?: SxProps
}

type SeparatorProps = {
  last?: boolean
}

const Separator = ({ last }: SeparatorProps) => (
  <Box
    sx={{
      display: last ? "none" : "block",
      width: 4,
      height: 4,
      mx: 1,
      borderRadius: "100%",
      backgroundColor: "#CCCCCC",
    }}
  />
)

const Ticket = ({ title, value, unity, sx }: TicketProps) => {
  const isThroughputData = Array.isArray(value)

  return (
    <Box
      paddingX={2}
      borderLeft="4px solid"
      borderColor="primary.light"
      sx={sx}
    >
      <Typography fontSize="1rem" color="primary.dark">
        {title}
      </Typography>
      <Box
        sx={{
          display: "flex",
          alignItems: "flex-end",
        }}
      >
        {isThroughputData ? (
          value.slice(-MAX_ARRAY_SIZE).map((data, index) => {
            return (
              <>
                <Box
                  sx={{
                    display: "flex",
                    alignItems: "center",
                  }}
                >
                  <Typography
                    fontSize="2.125rem"
                    color="grey.600"
                    lineHeight={1}
                  >
                    {data}
                  </Typography>
                  <Separator last={index === MAX_ARRAY_SIZE - 1} />
                </Box>
              </>
            )
          })
        ) : (
          <Typography fontSize="2.125rem" color="grey.600" lineHeight={1}>
            {value}
          </Typography>
        )}

        <Typography color="grey.600" pl={1} fontWeight={400}>
          {unity}
        </Typography>
      </Box>
    </Box>
  )
}

export default Ticket
