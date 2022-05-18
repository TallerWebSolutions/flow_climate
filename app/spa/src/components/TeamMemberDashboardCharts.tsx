import { BarChart } from "@material-ui/icons"
import { Grid } from "@mui/material"

import { TeamMember } from "../modules/teamMember/teamMember.types"

type TeamMemberDashboardChartsProps = {
  teamMember: TeamMember
}

const TeamMemberDashboardCharts = ({
  teamMember,
}: TeamMemberDashboardChartsProps) => {
  return (
    <Grid container spacing={2}>
      <Grid item xs={6}>
        <BarChart />
      </Grid>
    </Grid>
  )
}

export default TeamMemberDashboardCharts
