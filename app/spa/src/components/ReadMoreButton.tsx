import { Button, Typography } from "@mui/material"

type ReadMoreButtonProps = {
  handleDisplayPostContent: () => void
}

export const ReadMoreButton = ({handleDisplayPostContent}:ReadMoreButtonProps) => {
  return (
    <Button 
      sx={{
        width: '100%',
        height: '171px',
        disflex: 'flex',
        alignItems: 'end',
        justifyContent: 'center',
        position: 'absolute',
        bottom: 0,
        background: 'linear-gradient(360deg, #FFFFFF 0%, rgba(255, 255, 255, 0) 246.41%)',
        border: 0          
      }}
      onClick={handleDisplayPostContent}
    >
      <Typography variant="subtitle1" component="span" sx={{color: 'info.dark', textTransforme: 'uppercase'}}>
        Ver mais
      </Typography>
    </Button>
  )
}