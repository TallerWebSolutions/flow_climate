import { gql, useMutation } from "@apollo/client"
import {
  Modal,
  Typography,
  Box,
  FormGroup,
  FormControl,
  Input,
  InputLabel,
  Button,
  Select,
  MenuItem,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { Membership } from "../../team/team.types"
import { useTranslation } from "react-i18next"

const SERVICE_DELIVERY_REVIEW_ACTION = gql`
  mutation ServiceDeliveryReviewAction(
    $actionType: Int!
    $deadline: ISO8601Date!
    $description: String!
    $membershipId: ID!
    $sdrId: ID!
  ) {
    createServiceDeliveryReviewAction(
      actionType: $actionType
      deadline: $deadline
      description: $description
      membershipId: $membershipId
      sdrId: $sdrId
    ) {
      statusMessage
      serviceDeliveryReviewAction {
        id
      }
    }
  }
`

type ServiceDeliveryReviewActionsModalProps = {
  open: boolean
  handleClose: () => void
  memberships: Membership[]
  sdrId: String
}

const ServiceDeliveryReviewActionsModal = ({
  open,
  handleClose,
  memberships,
  sdrId,
}: ServiceDeliveryReviewActionsModalProps) => {
  const { register, handleSubmit, reset } = useForm()
  const { t } = useTranslation("serviceDeliveryReview")

  const [createServiceDeliveryReviewAction] = useMutation(
    SERVICE_DELIVERY_REVIEW_ACTION,
    {
      update: () => {
        reset()
        handleClose()
      },
      refetchQueries: ["ServiceDeliveryReview"],
    }
  )

  const handleServiceDeliveryReviewActionSubmit = (data: FieldValues) => {
    createServiceDeliveryReviewAction({
      variables: {
        actionType: Number(data.actionType || 0),
        deadline: data.deadline,
        description: data.description,
        membershipId: data.membershipId,
        sdrId: sdrId,
      },
    })
  }

  return (
    <Modal
      open={open}
      onClose={handleClose}
      aria-labelledby="modal-modal-title"
    >
      <Box
        sx={{
          position: "absolute" as "absolute",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          width: 680,
          height: 350,
          bgcolor: "background.paper",
          boxShadow: 24,
          p: 4,
        }}
      >
        <Typography
          id="modal-modal-title"
          variant="h2"
          component="h2"
          fontSize={"1.25rem"}
        >
          {t("actionItems.actionServiceDeliveryReview")}
        </Typography>
        <Box sx={{ marginTop: "42px" }}>
          <form
            onSubmit={handleSubmit(handleServiceDeliveryReviewActionSubmit)}
          >
            <FormGroup
              sx={{
                display: "grid",
                gridTemplateColumns: "repeat(2, 1fr)",
                gridColumnGap: "30px",
                gap: "40px",
                marginTop: "42px",
              }}
            >
              <FormControl>
                <InputLabel shrink htmlFor="deadline">
                  {t("actionItems.deadline")}
                </InputLabel>
                <Input
                  type="date"
                  {...register("deadline", { required: true })}
                />
              </FormControl>
              <FormControl>
                <InputLabel htmlFor="actionType">
                  {t("actionItems.actionType")}
                </InputLabel>
                <Select
                  autoWidth
                  labelId="active-members-select"
                  label={t("actionItems.actionType")}
                  {...register("actionType", { required: true })}
                >
                  <MenuItem value="0">
                    {t("actionType.technical_change")}
                  </MenuItem>
                  <MenuItem value="1">
                    {t("actionType.permissions_update")}
                  </MenuItem>
                  <MenuItem value="2">
                    {t("actionType.customer_alignment")}
                  </MenuItem>
                  <MenuItem value="3">
                    {t("actionType.internal_process_change")}
                  </MenuItem>
                  <MenuItem value="4">
                    {t("actionType.cadences_change")}
                  </MenuItem>
                  <MenuItem value="5">
                    {t("actionType.internal_comunication_change")}
                  </MenuItem>
                  <MenuItem value="6">{t("actionType.training")}</MenuItem>
                  <MenuItem value="7">{t("actionType.guidance")}</MenuItem>
                </Select>
              </FormControl>
              <FormControl>
                <InputLabel htmlFor="membershipId">
                  {t("actionItems.responsible")}
                </InputLabel>
                <Select
                  autoWidth
                  label={t("actionItems.responsible")}
                  {...register("membershipId", { required: true })}
                >
                  {memberships?.map((member, index) => (
                    <MenuItem key={index} value={member.id}>
                      {member.teamMemberName}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControl>
                <InputLabel htmlFor="description">
                  {t("actionItems.description")}
                </InputLabel>
                <Input
                  type="string"
                  {...register("description", { required: true })}
                />
              </FormControl>
              <Box sx={{ position: "absolute", bottom: 20 }}>
                <Box
                  sx={{
                    display: "flex",
                    justifyContent: "flex-start",
                    alignSelf: "flex-end",
                  }}
                >
                  <Button
                    onClick={handleClose}
                    variant="outlined"
                    sx={{ marginRight: 2 }}
                  >
                    {t("new.cancel")}
                  </Button>
                  <Button variant="contained" type="submit">
                    {t("new.save")}
                  </Button>
                </Box>
              </Box>
            </FormGroup>
          </form>
        </Box>
      </Box>
    </Modal>
  )
}

export default ServiceDeliveryReviewActionsModal
