import { FormGroup, FormControl, InputLabel } from "@mui/material"
import { useTranslation } from "react-i18next"

import BasicPage from "../../components/BasicPage"
import Table from "../../components/ui/Table"

const Demands = () => {
  const { t } = useTranslation("demands")
  const tableHeader = [] as any
  const tableRows = [] as any
  const tableFooter = [] as any
  const demandsCount = 20

  return (
    <BasicPage title={t("list.title")} breadcrumbsLinks={[]}>
      <form>
        <FormGroup>
          <FormControl>
            <InputLabel htmlFor="search">{t("list.form.search")}</InputLabel>
          </FormControl>
        </FormGroup>
      </form>
      <Table
        title={t("list.table.title", { demandsCount })}
        headerCells={tableHeader}
        footerCells={tableFooter}
        rows={tableRows}
      />
    </BasicPage>
  )
}

export default Demands
