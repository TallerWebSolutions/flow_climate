import { createContext } from "react"
import { User } from "../modules/user/user.types"

export const MeContext = createContext<{ me?: User }>({})
