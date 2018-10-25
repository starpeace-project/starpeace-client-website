import { library } from '@fortawesome/fontawesome-svg-core'

import {
  faBuilding,
  faComments,
  faEnvelope,
  faEye,
  faFolder as faFolderRegular,
  faQuestionCircle
} from '@fortawesome/free-regular-svg-icons'
library.add(faBuilding, faComments, faEnvelope, faEye, faFolderRegular, faQuestionCircle)

import {
  faAngleUp,
  faCheck,
  faCogs,
  faFastForward,
  faFlask,
  faFolder,
  faFolderOpen,
  faGlobe,
  faMagic,
  faMapMarkerAlt,
  faMapPin,
  faMinus,
  faMinusSquare,
  faParking,
  faPause,
  faPlay,
  faPlus,
  faPlusSquare,
  faRedoAlt,
  faSearchLocation,
  faSquare,
  faTimes,
  faToggleOff,
  faToggleOn,
  faToolbox,
  faUndoAlt,
  faUserSecret,
  faUserTie,
  faVolumeOff,
  faVolumeUp
} from '@fortawesome/free-solid-svg-icons'
library.add(faAngleUp, faCheck, faCogs, faFastForward, faFlask, faFolder, faFolderOpen, faGlobe, faMagic, faMapMarkerAlt, faMapPin,
  faMinus, faMinusSquare, faParking, faPause, faPlay, faPlus, faPlusSquare, faRedoAlt, faSearchLocation, faSquare, faTimes,
  faToggleOff, faToggleOn, faToolbox, faUndoAlt, faUserSecret, faUserTie, faVolumeOff, faVolumeUp)

import { faBimobject, faDiscord, faGithub, faMegaport, faMizuni, faMonero, faTwitter } from '@fortawesome/free-brands-svg-icons'
library.add(faBimobject, faDiscord, faGithub, faMegaport, faMizuni, faMonero, faTwitter)

import Vue from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

Vue.component('font-awesome-icon', FontAwesomeIcon)
