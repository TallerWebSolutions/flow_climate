import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { Demand } from "../../demand/demand.types"
import DemandBasicPage from "../../demand/components/DemandBasicPage"
import { useParams } from "react-router-dom"
import {
  Button,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Select,
  Typography,
} from "@mui/material"
import { useForm } from "react-hook-form"
import { FormElement } from "../../../components/ui/Form"

const CreateDemandEffort = () => {
  const { t } = useTranslation(["demandEffort"])
  const { t: commonT } = useTranslation(["common"])
  const params = useParams()
  const { register, handleSubmit } = useForm()

  const { data, loading } = useQuery<CreateDemandEffortDTO>(
    CREATE_DEMAND_EFFORT_QUERY,
    { variables: { externalId: params?.demand } }
  )

  const demand = data?.demand
  const team = demand?.team

  const onSubmit = () => alert("To be done!")

  return (
    <DemandBasicPage demand={demand} loading={loading} displayTabs={false}>
      <Typography component="h2" variant="h4" marginBottom={4}>
        {t("new.title")}
      </Typography>

      <form onSubmit={handleSubmit(onSubmit)}>
        <FormGroup>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel htmlFor="itemAssignment" shrink>
                {commonT("itemAssignment")}
              </InputLabel>
              <Select native {...register("itemAssignment")}>
                {demand?.itemAssignments?.map((itemAssignment, index) => (
                  <option
                    key={`${itemAssignment.id}--${index}`}
                    value={itemAssignment.id}
                  >
                    {itemAssignment.id}
                  </option>
                ))}
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="demandTransition" shrink>
                {commonT("demandTransition")}
              </InputLabel>
              <Select native {...register("demandTransition")}>
                {demand?.demandTransitions?.map((demandTransition, index) => (
                  <option
                    key={`${demandTransition.id}--${index}`}
                    value={demandTransition.id}
                  >
                    {demandTransition.id}
                  </option>
                ))}
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="startDate" shrink>
                {commonT("startDate")}
              </InputLabel>
              <Input
                type="datetime-local"
                defaultValue={new Date()}
                {...register("startDate")}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {commonT("endDate")}
              </InputLabel>
              <Input
                type="datetime-local"
                defaultValue={new Date()}
                {...register("endDate")}
              />
            </FormElement>
            <FormElement>
              <Button
                sx={{ alignSelf: "flex-start" }}
                type="submit"
                variant="outlined"
              >
                {t("new.title")}
              </Button>
            </FormElement>
          </Grid>
        </FormGroup>
      </form>
    </DemandBasicPage>
  )
}

const CREATE_DEMAND_EFFORT_QUERY = gql`
  query CreateDemandEffortPage($externalId: String!) {
    demand(externalId: $externalId) {
      id
      demandTitle
      externalId
      effortUpstream
      effortDownstream
      costToProject
      costToProject
      createdDate
      commitmentDate
      endDate

      itemAssignments {
        id
      }

      demandTransitions {
        id
      }
    }
  }
`

type CreateDemandEffortDTO = {
  demand?: Demand
}

export default CreateDemandEffort
