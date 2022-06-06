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
} from "@mui/material"
import { ReactElement } from "react"

type Cell = string | number | ReactElement

type Row = Cell[]

type TableProps = {
  rows: Row[]
  title?: string | ReactElement
  headerCells?: Cell[]
  footerCells?: Cell[]
  pagination?: TablePaginationProps
}

const Table = ({
  title,
  headerCells,
  rows,
  footerCells,
  pagination,
}: TableProps) => (
  <Box sx={{ marginY: 4 }}>
    <TableContainer component={Paper} sx={{ background: "white" }}>
      {title && (
        <Typography
          color="primary"
          variant="h6"
          component="h6"
          sx={{ padding: 2, display: "flex", justifyContent: "space-between" }}
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
          {rows.map((row, index) => (
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

export default Table
