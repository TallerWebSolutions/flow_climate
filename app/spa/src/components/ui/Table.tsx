import {
  Table as MUITable,
  TableBody,
  TableHead,
  TableContainer,
  Typography,
  TableRow,
  TableCell,
  Paper,
  TableFooter,
  TablePagination,
  Box,
  TablePaginationProps,
  Collapse,
  IconButton,
} from "@mui/material"
import { KeyboardArrowUp, KeyboardArrowDown } from "@material-ui/icons"

import { ReactElement, useState } from "react"

type Cell = string | number | ReactElement

type Row = Cell[]
export type RowWithCollapse = {
  rowInfo: Row
  collapseInfo: { collapseHeader: Cell[]; collapseBody: Cell[] }
}
type TableProps = {
  rows: Row[] | RowWithCollapse[]
  title?: string | ReactElement
  headerCells?: Cell[]
  footerCells?: Cell[]
  pagination?: TablePaginationProps
  withCollapse?: boolean
}

type TableRowWithCollapseProps = {
  row: RowWithCollapse
  index: number
}

const TableRowWithCollapse = ({ row, index }: TableRowWithCollapseProps) => {
  const [open, setOpen] = useState(false)

  return (
    <>
      <TableRow
        key={`${row.rowInfo[0]}--${index}`}
        sx={{
          borderBottom: "1px solid",
          borderBottomColor: "grey.200",
        }}
      >
        <TableCell width={52}>
          <IconButton
            aria-label="expand row"
            size="small"
            onClick={() => setOpen(!open)}
          >
            {open ? <KeyboardArrowUp /> : <KeyboardArrowDown />}
          </IconButton>
        </TableCell>
        {row.rowInfo.map((cell, index) => (
          <TableCell key={`${cell}--${index}`} sx={{ padding: 2 }}>
            {cell}
          </TableCell>
        ))}
      </TableRow>
      <TableRow>
        <TableCell style={{ padding: 0 }} colSpan={10}>
          <Collapse in={open} timeout="auto" unmountOnExit>
            <MUITable
              sx={{
                backgroundColor: "grey.A100",
                borderBottom: "1px solid",
                borderBottomColor: "grey.400",
              }}
            >
              <TableBody>
                <TableRow>
                  <TableCell width={52} />

                  {row.collapseInfo.collapseHeader.map(
                    (cell: Cell, index: number) => (
                      <TableCell key={`${cell}--${index}`} sx={{ padding: 2 }}>
                        {cell}
                      </TableCell>
                    )
                  )}
                </TableRow>
                <TableRow>
                  <TableCell width={52} />

                  {row.collapseInfo.collapseBody.map(
                    (cell: Cell, index: number) => (
                      <TableCell key={`${cell}--${index}`} sx={{ padding: 2 }}>
                        {cell}
                      </TableCell>
                    )
                  )}
                </TableRow>
              </TableBody>
            </MUITable>
          </Collapse>
        </TableCell>
      </TableRow>
    </>
  )
}

const Table = ({
  title,
  headerCells,
  rows,
  withCollapse = false,
  footerCells,
  pagination,
}: TableProps) => {
  return (
    <Box sx={{ marginY: 4 }}>
      <TableContainer component={Paper} sx={{ background: "white" }}>
        {title && (
          <Typography
            color="primary"
            variant="h6"
            component="h6"
            sx={{
              padding: 2,
              display: "flex",
              justifyContent: "space-between",
            }}
          >
            {title}
          </Typography>
        )}
        <MUITable>
          {headerCells && (
            <TableHead>
              <TableRow>
                {headerCells.map((cell, index) => (
                  <TableCell key={`${cell}--${index}`} sx={{ padding: 2 }}>
                    {cell}
                  </TableCell>
                ))}
              </TableRow>
            </TableHead>
          )}
          <TableBody>
            {withCollapse &&
              (rows as RowWithCollapse[]).map((row, index) => {
                return (
                  <TableRowWithCollapse
                    key={`${row.rowInfo[0]}--${index}`}
                    row={row}
                    index={index}
                  />
                )
              })}
            {!withCollapse &&
              (rows as Row[]).map((row, index) => (
                <TableRow
                  key={`${row[0]}--${index}`}
                  sx={{
                    borderBottom: "1px solid",
                    borderBottomColor: "grey.200",
                  }}
                >
                  {row.map((cell, index) => (
                    <TableCell key={`${cell}--${index}`} sx={{ padding: 2 }}>
                      {cell}
                    </TableCell>
                  ))}
                </TableRow>
              ))}
          </TableBody>
          {footerCells && (
            <TableFooter>
              <TableRow>
                {footerCells.map((cell, index) => (
                  <TableCell key={`${cell}--${index}`} sx={{ padding: 2 }}>
                    {cell}
                  </TableCell>
                ))}
              </TableRow>
            </TableFooter>
          )}
        </MUITable>
      </TableContainer>
      {pagination && (
        <TablePagination
          rowsPerPageOptions={[10]}
          count={pagination.count}
          rowsPerPage={pagination.rowsPerPage}
          page={pagination.page}
          onPageChange={pagination.onPageChange}
        />
      )}
    </Box>
  )
}

export default Table
