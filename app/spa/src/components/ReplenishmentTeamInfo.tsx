import { Card, CardContent, Typography, Grid } from "@mui/material"

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

const ReplenishmentTeamInfo = ({ team }: ReplenishmentTeamInfoProps) => (
  <Grid container spacing={2} justifyContent="space-around" my={2}>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Últimos Throughputs
          </Typography>
          {team.throughputData?.join(", ")}
          <Typography></Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Th Médio 4 Semanas
            <Typography>{team.averageThroughput?.value}</Typography>
          </Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Lead Time 4 semanas
          </Typography>
          {team.leadTime?.value?.toFixed(3)}
          <Typography></Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Limite de WIP
            <Typography>{team.workInProgress}</Typography>
          </Typography>
        </CardContent>
      </Card>
    </Grid>
  </Grid>
)

export default ReplenishmentTeamInfo
