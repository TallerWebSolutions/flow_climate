import BasicPage from "../../components/BasicPage"
import { useParams } from "react-router-dom"
import { gql, useQuery } from "@apollo/client"
import { Team } from "../../modules/team/team.types"
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Typography,
  Link,
} from "@mui/material"

import EditIcon from "@mui/icons-material/Edit"
import { useTranslation } from "react-i18next"
import DateLocale from "../../components/ui/DateLocale"

const MembershipsTable = () => {
  const { teamId, companySlug } = useParams()
  const { t } = useTranslation("membership")

  const { data, loading } = useQuery<MembershipsTableDTO>(
    MEMBERSHIPS_TABLE_QUERY,
    {
      variables: {
        teamId: Number(teamId),
      },
    }
  )

  const team = data?.team
  const company = team?.company
  const companyUrl = `/companies/${companySlug}`

  const breadcrumbsLinks = [
    { name: company?.name || "", url: companyUrl || "" },
    { name: team?.name || "", url: `${companyUrl}/teams/${teamId}` },
    { name: t("list.breadcrumb") },
  ]

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} loading={loading}>
      <Box sx={{ marginY: 4 }}>
        <TableContainer component={Paper} sx={{ background: "white" }}>
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
            {t("list.title")}
          </Typography>

          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t("fields.name")}</TableCell>
                <TableCell>{t("fields.memberRole")}</TableCell>
                <TableCell>{t("fields.hoursPerMonth")}</TableCell>
                <TableCell>{t("fields.startDate")}</TableCell>
                <TableCell>{t("fields.endDate")}</TableCell>
                <TableCell>{t("list.table.actions")}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {team?.memberships &&
                team.memberships.map((membership, index) => {
                  const editMemberURL = `${companyUrl}/teams/${teamId}/memberships/${membership?.id}/edit`

                  return (
                    <TableRow>
                      <TableCell>{membership.teamMemberName}</TableCell>
                      <TableCell>{membership.memberRoleDescription}</TableCell>
                      <TableCell>{membership.hoursPerMonth}</TableCell>
                      <TableCell>
                        {membership.startDate ? (
                          <DateLocale date={membership.startDate} />
                        ) : (
                          ""
                        )}
                      </TableCell>
                      <TableCell>
                        {membership.endDate ? (
                          <DateLocale date={membership.endDate} />
                        ) : (
                          ""
                        )}
                      </TableCell>
                      <TableCell>
                        {membership && (
                          <Link
                            key={`${membership.id}--${index}`}
                            href={editMemberURL}
                            sx={{ textDecoration: "none" }}
                          >
                            <EditIcon />
                          </Link>
                        )}
                      </TableCell>
                    </TableRow>
                  )
                })}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>
    </BasicPage>
  )
}

type MembershipsTableDTO = {
  team: Team
}

export const MEMBERSHIPS_TABLE_QUERY = gql`
  query MembershipsTable($teamId: ID!) {
    team(id: $teamId) {
      id
      name
      company {
        id
        name
      }
      memberships {
        id
        teamMemberName
        hoursPerMonth
        startDate
        endDate
        memberRole
        memberRoleDescription
      }
    }
  }
`

export default MembershipsTable
