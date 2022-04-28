import {
  Table as MUITable,
  TableBody,
  TableHead,
  TableContainer,
  Typography,
  TableRow,
  TableCell,
  Paper,
} from "@mui/material"
import { ReactElement } from "react"

type Cell = string | number | ReactElement

type Row = Cell[]

type TableProps = {
  title: string
  headerCells: string[]
  rows: Row[]
}

const Table = ({ title, headerCells, rows }: TableProps) => (
  <TableContainer component={Paper} sx={{ background: "white" }}>
    <Typography
      color="primary"
      variant="h6"
      component="h6"
      sx={{ padding: "16px " }}
    >
      {title}
    </Typography>
    <MUITable>
      <TableHead>
        <TableRow>
          {headerCells.map((cell, index) => (
            <TableCell key={`${cell}--${index}`} sx={{ padding: 2 }}>
              {cell}
            </TableCell>
          ))}
        </TableRow>
      </TableHead>
      <TableBody>
        {rows.map((row, index) => (
          <TableRow
            key={`${row[0]}--${index}`}
            sx={{
              borderBottom: "1px solid",
              borderBottomColor: "#ccc",
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
    </MUITable>
  </TableContainer>
)

export default Table
