import { Link, Tab as MUITab, Tabs as MUITabs, Typography } from "@mui/material"

export type Tab = {
  label: string
  to: string
}

type TabsProps = {
  currentPath: string
  tabs: Tab[]
}

export const Tabs = ({ tabs, currentPath }: TabsProps) => (
  <MUITabs value={currentPath}>
    {tabs.map(({ label, to }, index) => (
      <MUITab
        label={label}
        LinkComponent={to === currentPath ? Typography : Link}
        href={to}
        value={to}
        key={`${to}--${index}`}
      />
    ))}
  </MUITabs>
)
