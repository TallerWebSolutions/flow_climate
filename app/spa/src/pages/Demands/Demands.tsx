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
            {initiatives && (
              <FormElement>
                <InputLabel
                  htmlFor="initiatives"
                  sx={{ backgroundColor: "white" }}
                >
                  {t("list.form.initiatives")}
                </InputLabel>
                <Select native {...register("initiatives")}>
                  {initiatives.map((initiative, index) => (
                    <option key={`${initiative.id}--${index}`}>
                      {initiative.name}
                    </option>
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
