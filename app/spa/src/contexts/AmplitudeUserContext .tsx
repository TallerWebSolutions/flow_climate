import { createContext } from "react"
import User from "../modules/user/user.types"

export const AmplitudeUserContext = createContext<{ amplitudeUser?: User }>({})