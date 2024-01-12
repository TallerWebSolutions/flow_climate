import { useParams, useSearchParams } from "react-router-dom"
import { gql, useQuery } from "@apollo/client"
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
  FormControl,
  Select,
  MenuItem,
  InputLabel,
  SelectChangeEvent,
} from "@mui/material"
import EditIcon from "@mui/icons-material/Edit"
import { useTranslation } from "react-i18next"

import BasicPage from "../../components/BasicPage"
import DateLocale from "../../components/ui/DateLocale"
import { Team } from "../../modules/team/team.types"
import { formatCurrency } from "../../lib/currency"

const MembershipsTable = () => {
  const { teamId, companySlug } = useParams()
  const { t } = useTranslation("membership")
  const [searchParams, setSearchParams] = useSearchParams()
  const handleChangeActiveMembers = (event: SelectChangeEvent) =>
    setSearchParams((prev) => {
      prev.set("activeMemberships", event.target.value)
      return prev
    })

  const activeMemberships = searchParams.get("activeMemberships") !== "false"

  const { data, loading } = useQuery<MembershipsTableDTO>(
    MEMBERSHIPS_TABLE_QUERY,
    {
      variables: {
        teamId: Number(teamId),
        active: activeMemberships,
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
      <FormControl sx={{ minWidth: 240 }}>
        <InputLabel id="active-membership-select">
          {t("list.statusSelectLabel")}
        </InputLabel>
        <Select
          autoWidth
          labelId="active-membership-select"
          label={t("list.statusSelectLabel")}
          onChange={handleChangeActiveMembers}
          defaultValue={JSON.stringify(activeMemberships)}
        >
          <MenuItem value="true">{t("fields.status.active")}</MenuItem>
          <MenuItem value="false">{t("fields.status.inactive")}</MenuItem>
        </Select>
      </FormControl>
      <Box sx={{ marginY: 4 }}>
        <TableContainer component={Paper} sx={{ backgroundColor: "white" }}>
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
                <TableCell>{t("fields.hoursPerMonth")}</TableCell>
                <TableCell>{t("fields.memberRole")}</TableCell>
                <TableCell>{t("fields.startDate")}</TableCell>
                <TableCell>{t("fields.endDate")}</TableCell>
                <TableCell>{t("fields.status.title")}</TableCell>
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
                      <TableCell>{membership.hoursPerMonth}</TableCell>
                      <TableCell>
                        {formatCurrency(membership.expectedHourValue || 0)}
                      </TableCell>
                      <TableCell>
                        {formatCurrency(membership.realizedHourValue || 0)}
                      </TableCell>
                      <TableCell>{membership.memberRoleDescription}</TableCell>
                      <TableCell>
                        {membership.startDate && (
                          <DateLocale date={membership.startDate} />
                        )}
                      </TableCell>
                      <TableCell>
                        {membership.endDate && (
                          <DateLocale date={membership.endDate} />
                        )}
                      </TableCell>
                      <TableCell>
                        {membership.endDate
                          ? t("fields.status.inactive")
                          : t("fields.status.active")}
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
  query MembershipsTable($teamId: ID!, $active: Boolean!) {
    team(id: $teamId) {
      id
      name
      company {
        id
        name
      }
      memberships(active: $active) {
        id
        teamMemberName
        hoursPerMonth
        startDate
        endDate
        memberRole
        memberRoleDescription
        realizedHourValue
      	expectedHourValue
      }
    }
  }
`

export default MembershipsTable
