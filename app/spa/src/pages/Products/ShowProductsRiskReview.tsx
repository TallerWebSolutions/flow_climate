import { Link, useNavigate, useParams } from "react-router-dom"
import BasicPage from "../../components/BasicPage"
import useProductQuery from "../../hooks/useProductQuery"
import { useTranslation } from "react-i18next"
import {
  Box,
  Button,
  FormControl,
  FormGroup,
  Input,
  InputLabel,
  Select,
} from "@mui/material"
import { FieldValues, useForm } from "react-hook-form"
import { gql, useMutation, useQuery } from "@apollo/client"
import { Product } from "../../modules/product/product.types"
import { PRODUCT_QUERY } from "../../hooks/useProductQuery"


const ShowProductsRiskReview = () => {
    return (
      <h1>{"Vamos lá chchu!"}</h1>
    )
  }

export default ShowProductsRiskReview
