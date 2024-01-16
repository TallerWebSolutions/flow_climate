import {
  Box,
  Button,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Select,
} from "@mui/material"
import { FormElement } from "../../../components/ui/Form"
import SearchIcon from "@mui/icons-material/Search"
import { FieldValues, useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"

type ProjectsSearchFormProps = {
  projectsFilters: FieldValues
}

const ProjectsSearchForm = ({ projectsFilters }: ProjectsSearchFormProps) => {
  const { t } = useTranslation(["projects"])
  const { register } = useForm()

  return (
    <Box>
      <form>
        <FormGroup sx={{ marginBottom: 8 }}>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel id="status-filter">
                {t("projectsTable.filter.status")}
              </InputLabel>
              <Select
                native
                {...register("status")}
                defaultValue={projectsFilters.status}
              >
                <option value="">{t("projectsTable.filter.status")}</option>
                <option value="waiting">
                  {t("projectsTable.filter.statusWaiting")}
                </option>
                <option value="executing">
                  {t("projectsTable.filter.statusExecuting")}
                </option>
                <option value="maintenance">
                  {t("projectsTable.filter.statusMaintenance")}
                </option>
                <option value="finished">
                  {t("projectsTable.filter.statusFinished")}
                </option>
                <option value="cancelled">
                  {t("projectsTable.filter.statusCancelled")}
                </option>
                <option value="negotiating">
                  {t("projectsTable.filter.statusNegotiating")}
                </option>
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="startDate" shrink>
                {t("projectsTable.filter.startDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={projectsFilters.startDate}
                {...register("startDate")}
              />
            </FormElement>

            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {t("projectsTable.filter.endDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={projectsFilters.endDate}
                {...register("endDate")}
              />
            </FormElement>

            <FormElement>
              <InputLabel htmlFor={"name"} shrink>
                {t("projectsTable.filter.projectName")}
              </InputLabel>
              <Input
                type="text"
                defaultValue={projectsFilters.name}
                {...register("name")}
              />
            </FormElement>

            <FormElement>
              <Button sx={{ alignSelf: "flex-start" }} type="submit">
                <SearchIcon fontSize="large" color="primary" />
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
    </Box>
  )
}

export default ProjectsSearchForm
