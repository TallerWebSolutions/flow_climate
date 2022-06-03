import {
  FormGroup,
  FormControl,
  InputLabel,
  Input,
  Select,
  Grid,
  Button,
} from "@mui/material"
import SearchIcon from "@mui/icons-material/Search"
import { useTranslation } from "react-i18next"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useQuery } from "@apollo/client"
import { ReactNode, useContext } from "react"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"

// const DEMANDS_QUERY = gql``

const FormElement = ({ children }: { children: ReactNode }) => (
  <Grid item xs={4}>
    <FormControl sx={{ width: "100%" }}>{children}</FormControl>
  </Grid>
)

const Demands = () => {
  // const { data, loading } = useQuery(DEMANDS_QUERY)
  const loading = false
  const { me } = useContext(MeContext)
  const { t } = useTranslation("demands")
  const { register, handleSubmit } = useForm()
  const tableHeader = [] as any
  const tableRows = [] as any
  const tableFooter = [] as any
  const demandsCount = 20
  const initiatives = me?.currentCompany?.initiatives
  const projects = me?.currentCompany?.projects
  const teams = me?.currentCompany?.teams

  return (
    <BasicPage title={t("list.title")} breadcrumbsLinks={[]} loading={loading}>
      <form>
        <FormGroup>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel htmlFor="search">{t("list.form.search")}</InputLabel>
              <Input {...register("search")} />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="startDate" shrink>
                {t("list.form.startDate")}
              </InputLabel>
              <Input type="date" {...register("startDate")} />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {t("list.form.endDate")}
              </InputLabel>
              <Input type="date" {...register("endDate")} />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="status" sx={{ backgroundColor: "white" }}>
                {t("list.form.status")}
              </InputLabel>
              <Select native {...register("status")}>
                <option>'ALL_DEMANDS', 'All Activities'</option>
                <option>'NOT_COMMITTED', 'Not Committed'</option>
                <option>'WORK_IN_PROGRESS', 'Work in Progress'</option>
                <option>'DELIVERED_DEMANDS', 'Delivered'</option>
                <option>'NOT_STARTED', 'Not Started'</option>
                <option>'DISCARDED_DEMANDS', 'Discarded'</option>
                <option>'NOT_DISCARDED_DEMANDS', 'Not Discarded'</option>
              </Select>
            </FormElement>
            {initiatives && (
              <FormElement>
                <InputLabel
                  htmlFor="initiative"
                  sx={{ backgroundColor: "white" }}
                >
                  {t("list.form.initiative")}
                </InputLabel>
                <Select native {...register("initiative")}>
                  {initiatives.map((initiative, index) => (
                    <option key={`${initiative.id}--${index}`}>
                      {initiative.name}
                    </option>
                  ))}
                </Select>
              </FormElement>
            )}
            {projects && (
              <FormElement>
                <InputLabel
                  htmlFor="project"
                  sx={{ backgroundColor: "white", padding: 1 }}
                >
                  {t("list.form.project")}
                </InputLabel>
                <Select native {...register("project")}>
                  {projects.map((project, index) => (
                    <option key={`${project.id}--${index}`}>
                      {project.name}
                    </option>
                  ))}
                </Select>
              </FormElement>
            )}
            {teams && (
              <FormElement>
                <InputLabel
                  htmlFor="team"
                  sx={{ backgroundColor: "white", padding: 1 }}
                >
                  {t("list.form.team")}
                </InputLabel>
                <Select native {...register("team")}>
                  {teams.map((team, index) => (
                    <option key={`${team.id}--${index}`}>{team.name}</option>
                  ))}
                </Select>
              </FormElement>
            )}
            <FormElement>
              <Button
                sx={{ alignSelf: "flex-start" }}
                onClick={() => alert("To be done")}
              >
                <SearchIcon fontSize="large" color="primary" />
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
      <Table
        title={t("list.table.title", { demandsCount })}
        headerCells={tableHeader}
        footerCells={tableFooter}
        rows={tableRows}
      />
    </BasicPage>
  )
}

export default Demands
