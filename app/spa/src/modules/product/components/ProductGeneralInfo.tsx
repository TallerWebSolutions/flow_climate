import { Grid } from "@mui/material"

import { useTranslation } from "react-i18next"
import { Product } from "../product.types"
import LatestDeliveriesTable from "../../demand/components/LatestDeliveriesTable"
import ProductGeneralInfoTable from "./ProductGeneralInfoTable"

type ProductGeneralInfoProps = {
  product: Product
}

const ProductGeneralInfo = ({ product }: ProductGeneralInfoProps) => {
  const { t: tDemands } = useTranslation(["demands"])

  const lastestDeliveries = product.latestDeliveries
  const baseLink = `/companies/${product?.company?.slug}`

  return (
    <Grid container spacing={2}>
      <Grid item xs={4} sx={{ padding: "16px" }}>
        <ProductGeneralInfoTable product={product} />
      </Grid>

      <Grid item xs={8} sx={{ padding: "16px" }}>
        <LatestDeliveriesTable
          demands={lastestDeliveries}
          baseLink={baseLink}
        />
      </Grid>
    </Grid>
  )
}

export default ProductGeneralInfo
