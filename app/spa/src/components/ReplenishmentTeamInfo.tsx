import { Card, CardContent, Typography, Grid } from "@mui/material"

type ComparativeValue = {
  value: Number
  increased: Boolean
}

type TeamReplenishment = {
  throughputData: Number[]
  averageThroughput: ComparativeValue
  leadTime: ComparativeValue
  wip: Number
}

type ReplenishmentTeamInfoProps = {
  team: TeamReplenishment
}

const ReplenishmentTeamInfo = ({ team }: ReplenishmentTeamInfoProps) => (
  <Grid container spacing={2} justifyContent="space-around">
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Últimos Throughputs
          </Typography>
          {team.throughputData.join(", ")}
          <Typography></Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Th Médio 4 Semanas
            <Typography>{team.averageThroughput.value}</Typography>
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
          {team.leadTime.value.toFixed(3)}
          <Typography></Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Limite de WIP
            <Typography>{team.wip}</Typography>
          </Typography>
        </CardContent>
      </Card>
    </Grid>
  </Grid>
)

export default ReplenishmentTeamInfo
