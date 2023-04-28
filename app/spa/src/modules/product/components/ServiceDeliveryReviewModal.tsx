import {
  Box,
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Modal,
  Typography,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { useTranslation } from "react-i18next"
import useProductQuery from "../../../hooks/useProductQuery"
import { gql, useMutation } from "@apollo/client"
import { SERVICE_DELIVERY_REVIEW_TABLE_QUERY } from './ServiceDeliveryReviewTable'

const style = {
  position: "absolute" as "absolute",
  top: "50%",
  left: "50%",
  transform: "translate(-50%, -50%)",
  width: 680,
  height: 547,
  bgcolor: "background.paper",
  boxShadow: 24,
  p: 4,
}

const SERVICE_DELIVERY_REVIEW = gql`
  mutation ServiceDeliveryReview(
    $date: ISO8601Date!
    $productId: ID!
    $maxExpediteLate: Float!
    $maxLeadtime: Float!
    $maxQuality: Float!
    $minExpediteLate: Float!
    $minLeadtime: Float!
    $minQuality: Float!
    $sla: Int!
  ) {
    createServiceDeliveryReview(
      date: $date
      productId: $productId
      maxExpediteLate: $maxExpediteLate
      maxLeadtime: $maxLeadtime
      maxQuality: $maxQuality
      minExpediteLate: $minExpediteLate
      minLeadtime: $minLeadtime
      minQuality: $minQuality
      sla: $sla
    ) {
      statusMessage
    }
  }
`

type ServiceDeliveryReviewModalProps = {
  open: boolean
  handleClose: () => void
  productSlug: string
  productId: string
}

const ServiceDeliveryReviewModal = ({
  open,
  handleClose,
  productSlug,
  productId
}: ServiceDeliveryReviewModalProps) => {
  const { register, handleSubmit, reset } = useForm()
  const { product } = useProductQuery(productSlug)
  const { t } = useTranslation("serviceDeliveryReview")
  const [createServiceDeliveryReview] = useMutation(SERVICE_DELIVERY_REVIEW, {
    update: () => {
      reset()
      handleClose()
    },
    refetchQueries: [
      {query: SERVICE_DELIVERY_REVIEW_TABLE_QUERY, variables: { productId }} ,
    ]
  })

  const handleServiceDeliveryReviewSubmit = (data: FieldValues) => {
    createServiceDeliveryReview({
      variables: {
        date: new Date(data.date).toISOString(),
        productId: product?.id,
        maxExpediteLate: parseFloat(data.maxExpediteLate),
        maxLeadtime: parseFloat(data.maxLeadtime),
        maxQuality: parseFloat(data.maxQuality),
        minExpediteLate: parseFloat(data.minExpediteLate),
        minLeadtime: parseFloat(data.minLeadtime),
        minQuality: parseFloat(data.minQuality),
        sla: parseFloat(data.sla),
      },
    })
  }

  return (
    <>
      <Modal
        open={open}
        onClose={handleClose}
        aria-labelledby="modal-modal-title"
        aria-describedby="modal-modal-description"
      >
        <Box sx={style}>
          <Typography
            id="modal-modal-title"
            variant="h2"
            component="h2"
            fontSize={"1.25rem"}
          >
            {t("newModal.title")}
          </Typography>
          <Box sx={{ marginTop: "42px" }}>
            <form onSubmit={handleSubmit(handleServiceDeliveryReviewSubmit)}>
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
                  <InputLabel shrink htmlFor="date">
                    {t("newModal.revisionDate")}
                  </InputLabel>
                  <Input
                    type="date"
                    {...register("date", { required: true })}
                  />
                </FormControl>
                <FormControl>
                  <InputLabel htmlFor="sla">
                    {t("newModal.slaToPull")} ({t("newModal.hours")})
                  </InputLabel>
                  <Input
                    type="number"
                    inputProps={{ min: 0 }}
                    {...register("sla", { required: true })}
                  />
                </FormControl>
                <FormControl>
                  <InputLabel htmlFor="minExpediteLate">
                    {t("newModal.minExpediteLate")} (%)
                  </InputLabel>
                  <Input
                    type="number"
                    inputProps={{ min: 0, max: 100, step: 0.1 }}
                    {...register("minExpediteLate", { required: true })}
                  />
                </FormControl>
                <FormControl>
                  <InputLabel htmlFor="maxExpediteLate">
                    {t("newModal.maxExpediteLate")} (%)
                  </InputLabel>
                  <Input
                    type="number"
                    inputProps={{ min: 0, max: 100, step: 0.1 }}
                    {...register("maxExpediteLate", { required: true })}
                  />
                </FormControl>
                <FormControl>
                  <InputLabel htmlFor="minLeadtime">
                    {t("newModal.minLeadtime")} ({t("newModal.hours")})
                  </InputLabel>
                  <Input
                    type="number"
                    inputProps={{ min: 0, step: 0.1 }}
                    {...register("minLeadtime", { required: true })}
                  />
                </FormControl>
                <FormControl>
                  <InputLabel htmlFor="maxLeadtime">
                    {t("newModal.maxLeadtime")} ({t("newModal.hours")})
                  </InputLabel>
                  <Input
                    type="number"
                    inputProps={{ min: 0, step: 0.1 }}
                    {...register("maxLeadtime", { required: true })}
                  />
                </FormControl>
                <FormControl>
                  <InputLabel htmlFor="minQuality">
                    {t("newModal.minQuality")} (%)
                  </InputLabel>
                  <Input
                    type="number"
                    inputProps={{ min: 0, max: 100, step: 0.1 }}
                    {...register("minQuality", { required: true })}
                  />
                </FormControl>
                <FormControl>
                  <InputLabel htmlFor="maxQuality">
                    {t("newModal.maxQuality")} (%)
                  </InputLabel>
                  <Input
                    type="number"
                    inputProps={{ min: 0, max: 100, step: 0.1 }}
                    {...register("maxQuality", { required: true })}
                  />
                </FormControl>
              </FormGroup>
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
                    {t("newModal.cancel")}
                  </Button>
                  <Button variant="contained" type="submit">
                    {t("newModal.save")}
                  </Button>
                </Box>
              </Box>
            </form>
          </Box>
        </Box>
      </Modal>
    </>
  )
}

export default ServiceDeliveryReviewModal
