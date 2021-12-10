import { Card, CardContent, Typography, Grid } from "@mui/material"

const ReplenishmentTeamInfo = () => (
  <Grid container spacing={2} justifyContent="space-around">
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Últimos Throughputs
          </Typography>
          <Typography>Word of the Day</Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Th Médio 4 Semanas
          </Typography>
          <Typography>Word of the Day</Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Lead Time 4 semanas
          </Typography>
          <Typography>Word of the Day</Typography>
        </CardContent>
      </Card>
    </Grid>
    <Grid item>
      <Card>
        <CardContent>
          <Typography variant="h6" component="h5">
            Limite de WIP
          </Typography>
          <Typography>Word of the Day</Typography>
        </CardContent>
      </Card>
    </Grid>
  </Grid>
)

export default ReplenishmentTeamInfo