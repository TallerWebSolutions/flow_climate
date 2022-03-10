import {
  Card as MUICard,
  CardProps,
  CardContent,
  CardContentProps,
  Typography,
  Box,
} from "@mui/material"
import ErrorIcon from "@mui/icons-material/Error"
import CheckCircleIcon from "@mui/icons-material/CheckCircle"

type CustomCardContentProps = {
  title: string
  subtitle: string
  type: CardType
} & CardContentProps

const CustomCardContent = ({
  children,
  title,
  subtitle,
  type,
  ...props
}: CustomCardContentProps) => (
  <CardContent {...props} sx={{ ":last-child": { paddingBottom: 2 } }}>
    <Box sx={{ display: "flex", alignItems: "center" }}>
      {type === CardType.WARNING && <ErrorIcon color={type} sx={{ mr: 1 }} />}
      {type === CardType.SUCCESS && (
        <CheckCircleIcon color={type} sx={{ mr: 1 }} />
      )}
      <Typography variant="h6" component="h6">
        {title}
      </Typography>
    </Box>

    <Typography
      variant="body2"
      component="span"
      color="grey.600"
      mb={1}
      display="block"
    >
      {subtitle}
    </Typography>
    {children}
  </CardContent>
)

export enum CardType {
  PRIMARY = "primary",
  WARNING = "warning",
  SUCCESS = "success",
}

type CustomCardProps = {
  subtitle: string
  title: string
  type: CardType
} & CardProps

const Card = ({
  children,
  title,
  subtitle,
  type,
  ...props
}: CustomCardProps) => (
  <MUICard
    {...props}
    sx={{
      borderColor: type === CardType.PRIMARY ? "#ccc" : `${type}.light`,
    }}
  >
    <CustomCardContent title={title} subtitle={subtitle} type={type}>
      {children}
    </CustomCardContent>
  </MUICard>
)

export default Card
