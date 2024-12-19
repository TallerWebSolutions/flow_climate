import { useTranslation } from "react-i18next"
import { gql, useMutation, useQuery } from "@apollo/client"
import { Demand } from "../../demand/demand.types"
import DemandBasicPage from "../../demand/components/DemandBasicPage"
import { useNavigate, useParams } from "react-router-dom"
import {
  Button,
  FormGroup,
  Grid,
  Input,
  InputLabel,
  Select,
  Typography,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { FormElement } from "../../../components/ui/Form"
import { DemandEffort } from "../demandEffort.types"
import { useContext } from "react"
import { MeContext } from "../../../contexts/MeContext"

const CreateDemandEffort = () => {
  const { t } = useTranslation(["demandEffort"])
  const { t: commonT } = useTranslation(["common"])
  const params = useParams()
  const { register, handleSubmit } = useForm()
  const { me } = useContext(MeContext)
  const navigate = useNavigate()

  const { data, loading } = useQuery<CreateDemandEffortPageDTO>(
    CREATE_DEMAND_EFFORT_QUERY,
    { variables: { externalId: params?.demand } }
  )

  const [createDemandEffort] = useMutation<CreateDemandEffortDTO>(
    CREATE_DEMAND_EFFORT_MUTATION
  )

  const demand = data?.demand

  const onSubmit = (values: FieldValues) => {
    console.log({ values })
    createDemandEffort({
      variables: {
        ...values,
        demandExternalId: demand?.externalId,
        startDate: new Date(values.startDate).toISOString(),
        endDate: new Date(values.endDate).toISOString(),
      },
      onCompleted: () =>
        navigate(
          `/companies/${me?.currentCompany?.slug}/demands/${demand?.externalId}/demand_efforts`
        ),
    })
  }

  return (
    <DemandBasicPage demand={demand} loading={loading} displayTabs={false}>
      <Typography component="h2" variant="h4" marginBottom={4}>
        {t("new.title")}
      </Typography>

      <form onSubmit={handleSubmit(onSubmit)}>
        <FormGroup>
          <Grid container spacing={5}>
            <FormElement>
              <InputLabel htmlFor="itemAssignmentId" shrink>
                {commonT("itemAssignment")}
              </InputLabel>
              <Select
                native
                {...register("itemAssignmentId", { required: true })}
              >
                <option value="" />
                {demand?.itemAssignments?.map((itemAssignment, index) => (
                  <option
                    key={`${itemAssignment.id}--${index}`}
                    value={itemAssignment.id}
                  >
                    {itemAssignment.teamMemberName}
                  </option>
                ))}
              </Select>
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="demandTransitionId" shrink>
                {commonT("demandTransition")}
              </InputLabel>
              <Select
                native
                {...register("demandTransitionId", { required: true })}
              >
                <option value="" />
                {demand?.demandTransitions?.map((demandTransition, index) => (
                  <option
                    key={`${demandTransition.id}--${index}`}
                    value={demandTransition.id}
                  >
                    {demandTransition.stageName}
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
                {...register("startDate", { required: true })}
              />
            </FormElement>
            <FormElement>
              <InputLabel htmlFor="endDate" shrink>
                {commonT("endDate")}
              </InputLabel>
              <Input
                type="datetime-local"
                defaultValue={new Date()}
                {...register("endDate", { required: true })}
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
        teamMemberName
      }

      demandTransitions {
        id
        stageName
      }
    }
  }
`

const CREATE_DEMAND_EFFORT_MUTATION = gql`
  mutation CreateDemandEffort(
    $demandExternalId: ID!
    $startDate: ISO8601DateTime!
    $endDate: ISO8601DateTime!
    $demandTransitionId: ID!
    $itemAssignmentId: ID!
  ) {
    createDemandEffort(
      demandExternalId: $demandExternalId
      startDate: $startDate
      endDate: $endDate
      demandTransitionId: $demandTransitionId
      itemAssignmentId: $itemAssignmentId
    ) {
      statusMessage
      demandEffort {
        id
      }
    }
  }
`

type CreateDemandEffortPageDTO = {
  demand?: Demand
}

type CreateDemandEffortDTO = {
  createDemandEffort?: {
    statusMessage: string
    demandEffort?: DemandEffort
  }
}

export default CreateDemandEffort
