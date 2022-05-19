import { Grid } from "@mui/material"

import { TeamMember } from "../modules/teamMember/teamMember.types"
import { BarChart } from "./charts/BarChart"

type TeamMemberDashboardChartsProps = {
  teamMember: TeamMember
}

const TeamMemberDashboardCharts = ({
  teamMember,
}: TeamMemberDashboardChartsProps) => {
  const leadTimeHistogramChartData = teamMember.leadTimeHistogramChartData
  return (
    <Grid container spacing={2}>
      {leadTimeHistogramChartData && (
        <Grid item xs={6}>
          <BarChart
            indexBy="key"
            data={leadTimeHistogramChartData}
            keys={["value"]}
            padding={0}
          />
        </Grid>
      )}
    </Grid>
  )
}

export default TeamMemberDashboardCharts
