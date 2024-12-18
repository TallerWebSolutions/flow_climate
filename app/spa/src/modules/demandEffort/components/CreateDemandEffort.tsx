import { useTranslation } from "react-i18next"
import { gql, useQuery } from "@apollo/client"
import { Demand } from "../../demand/demand.types"
import DemandBasicPage from "../../demand/components/DemandBasicPage"
import { useParams } from "react-router-dom"
import {
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
              <InputLabel htmlFor="membership" shrink>
                {commonT("membership")}
              </InputLabel>
              <Select native {...register("membership")}>
                {team?.memberships?.map((membership, index) => {
                  return (
                    <option
                      value={membership.id}
                      key={`${membership.id}--${index}`}
                    >
                      {membership.teamMemberName}
                    </option>
                  )
                })}
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="startDate" shrink>
                {commonT("startDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={new Date()}
                {...register("startDate")}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {commonT("endDate")}
              </InputLabel>
              <Input
                type="date"
                defaultValue={new Date()}
                {...register("endDate")}
              />
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

      team {
        id
        memberships {
          id
          teamMemberName
        }
      }
    }
  }
`

type CreateDemandEffortDTO = {
  demand?: Demand
}

export default CreateDemandEffort
