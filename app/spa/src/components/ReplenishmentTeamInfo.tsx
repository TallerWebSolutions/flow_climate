import { Card, CardContent, Typography, Grid } from "@mui/material"

const ReplenishmentTeamInfo = (props: any) => {
  return (
      <Grid container spacing={2} justifyContent="space-around">
        <Grid item>
          <Card>
            <CardContent>
              <Typography variant="h6" component="h5">
                Últimos Throughputs
              </Typography>
              <Typography>{ props['teamProps']['team']['teamThroughputData'].join(', ') }</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item>
          <Card>
            <CardContent>
              <Typography variant="h6" component="h5">
                Th Médio 4 Semanas
              </Typography>
              <Typography>{ props['teamProps']['team']['averageTeamThroughput'] }</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item>
          <Card>
            <CardContent>
              <Typography variant="h6" component="h5">
                Lead Time 4 semanas
              </Typography>
              <Typography>{ props['teamProps']['team']['teamLeadTime'].toFixed(3) }</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item>
          <Card>
            <CardContent>
              <Typography variant="h6" component="h5">
                Limite de WIP
              </Typography>
              <Typography>{ props['teamProps']['team']['teamWip'] }</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
  )
}

export default ReplenishmentTeamInfo