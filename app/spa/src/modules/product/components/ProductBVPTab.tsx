import ProductDetails from "./ProductDetails"
import { useParams } from "react-router-dom"
import { gql, useMutation, useQuery } from "@apollo/client"
import { Product } from "../product.types"
import { Fragment } from "react"
import { Paper, Select, Table, TableContainer } from "@mui/material"
import { useTranslation } from "react-i18next"
import { DemandScoreMatrix } from "../../demand/demand.types"

const ProductBVPTab = () => {
  const { t } = useTranslation(["bvpTab"])
  const params = useParams()

  const [updateDemandScoreMatrix] = useMutation<UpdateDemandScoreMatrixDTO>(
    UPDATE_DEMAND_SCORE_MATRIX_MUTATION
  )

  const productSlug = params.productSlug || ""
  const { data, loading } = useQuery<ProductBVPTabDTO>(PRODUCT_BVP_QUERY, {
    variables: { productSlug, limit: 20, offset: 0 },
    notifyOnNetworkStatusChange: true,
  })

  const product = data?.product
  const demands = product?.demands || []

  return (
    <>
      {product && (
        <ProductDetails product={product} loading={loading}>
          <TableContainer component={Paper} sx={{ background: "white" }}>
            <Table
              sx={{
                th: {
                  textAlign: "left",
                  padding: 2,
                },
                td: {
                  minWidth: "200px",
                  padding: 2,
                  "&:first-of-type": {
                    minWidth: "initial",
                  },
                },
                "tr:nth-of-type(odd)": {
                  backgroundColor: "action.hover",
                },
              }}
            >
              <thead>
                <tr>
                  <th>{t("bvpTab.demands.title")}</th>
                  <th>{t("bvpTab.demands.points")}</th>
                  {demands[0].demandScoreMatrices?.map((scoreMatrix, index) => {
                    return (
                      <th key={`${scoreMatrix.id}-${index}`}>
                        {
                          scoreMatrix.scoreMatrixAnswer?.scoreMatrixQuestion
                            ?.description
                        }
                      </th>
                    )
                  })}
                </tr>
              </thead>
              <tbody>
                {demands?.map((demand, index) => {
                  return (
                    <tr key={`${demand.id}-${index}`}>
                      <td>{demand.demandTitle}</td>
                      <td>{demand.demandScore}</td>
                      {demand.demandScoreMatrices?.map((scoreMatrix, index) => {
                        return (
                          <td key={`${scoreMatrix.id}-${index}`}>
                            <Select
                              native
                              defaultValue={scoreMatrix.scoreMatrixAnswer?.id}
                              onChange={(e) =>
                                updateDemandScoreMatrix({
                                  variables: {
                                    matrixId: scoreMatrix.id,
                                    answerId: e.target.value,
                                  },
                                })
                              }
                            >
                              {scoreMatrix.scoreMatrixAnswer?.scoreMatrixQuestion?.scoreMatrixAnswers?.map(
                                (scoreMatrixAnswer, index) => {
                                  return (
                                    <option
                                      key={`${scoreMatrixAnswer.id}-${index}`}
                                      value={scoreMatrixAnswer.id}
                                    >
                                      {scoreMatrixAnswer.description}
                                    </option>
                                  )
                                }
                              )}
                            </Select>
                          </td>
                        )
                      })}
                    </tr>
                  )
                })}
              </tbody>
            </Table>
          </TableContainer>
        </ProductDetails>
      )}
    </>
  )
}

const PRODUCT_BVP_QUERY = gql`
  query ProductBVP($productSlug: String!, $limit: Int, $offset: Int) {
    product(slug: $productSlug) {
      id
      ...productDetails
      demands(limit: $limit, offset: $offset, sortCriteria: DEMAND_SCORE) {
        id
        demandTitle
        demandScore
        demandScoreMatrices {
          id
          scoreMatrixAnswer {
            id
            description
            scoreMatrixQuestion {
              id
              description
              scoreMatrixAnswers {
                id
                description
              }
            }
          }
        }
      }
    }
  }

  ${ProductDetails.fragments}
`

const UPDATE_DEMAND_SCORE_MATRIX_MUTATION = gql`
  mutation UpdateDemandScoreMatrix($matrixId: ID!, $answerId: ID!) {
    updateDemandScoreMatrix(matrixId: $matrixId, answerId: $answerId) {
      statusMessage
      demandScoreMatrix {
        id
        scoreMatrixAnswer {
          id
          description
        }
      }
    }
  }
`

type ProductBVPTabDTO = {
  product?: Product
}

type UpdateDemandScoreMatrixDTO = {
  updateDemandScoreMatrix: {
    statusMessage: string
    demandScoreMatrix?: DemandScoreMatrix
  }
}

export default ProductBVPTab
