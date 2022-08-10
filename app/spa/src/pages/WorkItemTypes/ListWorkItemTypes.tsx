import { gql, useMutation, useQuery } from "@apollo/client"
import CheckIcon from "@mui/icons-material/Check"
import { useContext } from "react"
import { useTranslation } from "react-i18next"
import { Link } from "react-router-dom"
import { Button } from "@mui/material"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"
import { MeContext } from "../../contexts/MeContext"
import { useConfirm } from "material-ui-confirm"
import { TEAMS_QUERY } from "../Teams/Teams"
import { MessagesContext } from "../../contexts/MessageContext"
import DeleteOutlineOutlinedIcon from "@mui/icons-material/DeleteOutlineOutlined"

const WORK_ITEM_TYPES_QUERY = gql`
  query WorkItemTypesList {
    workItemTypes {
      id
      name
      qualityIndicatorType
      itemLevel
    }
  }
`

const DELETE_WORK_ITEM_MUTATION = gql`
  mutation DeleteWorkItemType($workItemTypeId: String!) {
    deleteWorkItemType(workItemTypeId: $workItemTypeId) {
      statusMessage
    }
  }
`

type WorkItemType = {
  id: string
  name: string
  qualityIndicatorType: boolean
  itemLevel: string
}

type WorkItemTypesDTO = {
  workItemTypes: WorkItemType[]
}

type DeleteWorkItemTypeDTO = {
  deleteWorkItemType: {
    statusMessage: string
  }
}

const ListWorkItemTypes = () => {
  const { data, loading } = useQuery<WorkItemTypesDTO>(WORK_ITEM_TYPES_QUERY)
  const { t } = useTranslation("workItemTypes")
  const { me } = useContext(MeContext)
  const { pushMessage } = useContext(MessagesContext)

  const [deleteWorkItemType] = useMutation<DeleteWorkItemTypeDTO>(
    DELETE_WORK_ITEM_MUTATION,
    {
      update: (_, { data }) => {
        const mutationResult =
          data?.deleteWorkItemType.statusMessage === "SUCCESS"

        pushMessage({
          text: mutationResult
            ? t("deleteWorkItemType.messageSuccess")
            : t("deleteWorkItemType.messageFail"),
          severity: mutationResult ? "success" : "error",
        })
      },
      refetchQueries: [{ query: WORK_ITEM_TYPES_QUERY }],
    }
  )
  const deleteWorkItemTypeModal = useConfirm()

  const companyUrl = `/companies/${me?.currentCompany?.slug}`
  const breadcrumbsLinks = [
    { name: me?.currentCompany?.name || "", url: companyUrl },
    {
      name: t("table.title"),
    },
  ]
  const headerCells = [
    t("table.name"),
    t("table.qualityIndicatorType"),
    t("table.itemLevel"),
  ]

  const handleOnDeleteWorkItemType = (id: string) => {
    deleteWorkItemTypeModal({
      title: t("deleteWorkItemType.title"),
      description: t("deleteWorkItemType.modalBody"),
    }).then(() => {
      deleteWorkItemType({
        variables: { workItemTypeId: id },
      })
    })
  }

  const workItemTypesRows =
    data?.workItemTypes.map((itemType) => [
      itemType.name,
      itemType.qualityIndicatorType ? <CheckIcon color="primary" /> : "",
      itemType.itemLevel,
      <Button onClick={() => handleOnDeleteWorkItemType(itemType.id)}>
        <DeleteOutlineOutlinedIcon color={"primary"} />
      </Button>,
    ]) || []

  return (
    <BasicPage breadcrumbsLinks={breadcrumbsLinks} loading={loading}>
      <Button
        component={Link}
        variant="contained"
        to={`${companyUrl}/work_item_types/new`}
        sx={{ float: "right", marginBottom: "2rem" }}
      >
        {t("table.create")}
      </Button>
      <Table
        rows={workItemTypesRows}
        headerCells={headerCells}
        title={t("table.title")}
      />
    </BasicPage>
  )
}

export default ListWorkItemTypes
