import {
  Card,
  CardContent,
  Typography,
  Grid,
  Divider,
  CardContentProps,
} from "@mui/material"
import { Box } from "@mui/system"
import { Fragment } from "react"

type ComparativeValue = {
  value: number
  increased: boolean
}

type TeamReplenishment = {
  throughputData: number[]
  averageThroughput: ComparativeValue
  leadTime: ComparativeValue
  workInProgress: number
}

type ReplenishmentTeamInfoProps = {
  team: TeamReplenishment
}

type CustomCardContentProps = {
  title: string
  subtitle: string
} & CardContentProps

const CustomCardContent = ({
  children,
  title,
  subtitle,
  ...props
}: CustomCardContentProps) => (
  <CardContent {...props} sx={{ ":last-child": { paddingBottom: 2 } }}>
    <Typography variant="h6" component="h6">
      {title}
    </Typography>
    <Typography
      variant="body2"
      component="span"
      color="grey.600"
      mb={1}
      display="block"
    >
      {subtitle}
    </Typography>
    {children}
  </CardContent>
)

const ReplenishmentTeamInfo = ({ team }: ReplenishmentTeamInfoProps) => (
  <Grid container spacing={15} mb={4}>
    <Grid item xs={4}>
      <Card>
        <CustomCardContent title="Throughput" subtitle="Últimas quatro semanas">
          <Box display="flex">
            {team.throughputData?.map((th, index, list) => (
              <Fragment>
                <Typography key={`value--${index}`}>{th}</Typography>
                {index < list.length - 1 && (
                  <Divider
                    key={`divider--${index}`}
                    variant="middle"
                    orientation="vertical"
                    flexItem
                    sx={{ marginX: 2 }}
                  />
                )}
              </Fragment>
            ))}
          </Box>
        </CustomCardContent>
      </Card>
    </Grid>
    <Grid item xs={4}>
      <Card>
        <CustomCardContent title="Lead Time" subtitle="Últimas quatro semanas">
          <Typography>{team.leadTime?.value?.toFixed(2)}</Typography>
        </CustomCardContent>
      </Card>
    </Grid>
    <Grid item xs={4}>
      <Card>
        <CustomCardContent
          title="Work in Progress"
          subtitle="WiP máximo do time:"
        >
          <Typography>{team.workInProgress}</Typography>
        </CustomCardContent>
      </Card>
    </Grid>
  </Grid>
)

export default ReplenishmentTeamInfo
