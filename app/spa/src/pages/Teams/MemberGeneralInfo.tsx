import {
  Box,
  Link,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableRow,
  Typography,
} from "@mui/material"
import { Team } from "../../modules/team/team.types"
import { useTranslation } from "react-i18next"
import DateLocale from "../../components/ui/DateLocale"
import React from "react"
import { useParams } from "react-router-dom"
import { secondsToDays } from "../../lib/date"

type MemberGeneralInfoProps = {
  team: Team
}

const MemberGeneralInfo = ({ team }: MemberGeneralInfoProps) => {
  const { t } = useTranslation("teams")
  const { teamId, companySlug } = useParams()

  return (
    <Box sx={{ marginY: 4 }}>
      <Typography
        color="primary"
        variant="h6"
        component="h6"
        sx={{
          padding: 2,
          display: "flex",
          justifyContent: "space-between",
        }}
      >
        {t("dashboard.infoTable")}
      </Typography>

      <TableContainer component={Paper} sx={{ background: "white" }}>
        <Table>
          <TableBody>
            <TableRow>
              <TableCell>{t("dashboard.name")}</TableCell>
              <TableCell>{team.name}</TableCell>
            </TableRow>
            <TableRow>
              <TableCell>{t("dashboard.startDate")}</TableCell>
              <TableCell>
                {team.startDate ? <DateLocale date={team.startDate} /> : ""}
              </TableCell>
            </TableRow>
            <TableRow>
              <TableCell>{t("dashboard.endDate")}</TableCell>
              <TableCell>
                {team.endDate ? <DateLocale date={team.endDate} /> : ""}
              </TableCell>
            </TableRow>
            <TableRow>
              <TableCell>{t("dashboard.activeMembersCount")}</TableCell>
              <TableCell>
                <Link
                  href={`/companies/${companySlug}/teams/${teamId}/memberships/efficiency_table`}
                >
                  {t("dashboard.membersCount", {
                    membersCount: team?.activeBillableCount ?? 0,
                  })}
                </Link>
              </TableCell>
            </TableRow>
            <TableRow>
              <TableCell>{t("dashboard.leadTimeP65")}</TableCell>
              <TableCell>{`${secondsToDays(team.leadTimeP65 || 0)} ${t(
                "dashboard.days"
              )}`}</TableCell>
            </TableRow>
            <TableRow>
              <TableCell>{t("dashboard.leadTimeP80")}</TableCell>
              <TableCell>{`${secondsToDays(team.leadTimeP80 || 0)} ${t(
                "dashboard.days"
              )}`}</TableCell>
            </TableRow>
            <TableRow>
              <TableCell>{t("dashboard.leadTimeP95")}</TableCell>
              <TableCell>{`${secondsToDays(team.leadTimeP95 || 0)} ${t(
                "dashboard.days"
              )}`}</TableCell>
            </TableRow>
            <TableRow>
              <TableCell>{t("dashboard.capacityOfHours")}</TableCell>
              <TableCell>{`${team.availableHoursInMonthFor} h`}</TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  )
}

export default MemberGeneralInfo
