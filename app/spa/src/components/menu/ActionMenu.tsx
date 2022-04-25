import { useState } from "react"
import Button from "@mui/material/Button"
import Menu from "@mui/material/Menu"
import MenuItem from "@mui/material/MenuItem"
import SettingsIcon from "@mui/icons-material/Settings"

type ActionMenuItem = {
  name: string
  onClick?: () => {}
  href?: string
}

type ActionMenuProps = {
  items: ActionMenuItem[]
}

const ActionMenu = ({ items }: ActionMenuProps) => {
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null)
  const open = Boolean(anchorEl)
  const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    setAnchorEl(event.currentTarget)
  }
  const handleClose = () => {
    setAnchorEl(null)
  }

  return (
    <div>
      <Button
        id="basic-button"
        aria-controls={open ? "basic-menu" : undefined}
        aria-haspopup="true"
        aria-expanded={open ? "true" : undefined}
        onClick={handleClick}
        sx={{ cursor: "pointer" }}
      >
        <SettingsIcon />
      </Button>
      <Menu
        id="basic-menu"
        anchorEl={anchorEl}
        open={open}
        onClose={handleClose}
        MenuListProps={{
          "aria-labelledby": "basic-button",
        }}
      >
        {items.map((item, index) => (
          <MenuItem
            key={`${item.name}--${index}`}
            component="a"
            href={item.href}
            onClick={item.onClick}
          >
            {item.name}
          </MenuItem>
        ))}
      </Menu>
    </div>
  )
}

export default ActionMenu
