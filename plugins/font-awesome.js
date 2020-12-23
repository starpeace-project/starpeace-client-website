import { library } from '@fortawesome/fontawesome-svg-core'

import {
  faBuilding,
  faCircle,
  faComments,
  faEnvelope,
  faEye,
  faFolder as faFolderRegular,
  faQuestionCircle,
  faSquare as faSquareRegular
} from '@fortawesome/free-regular-svg-icons'
library.add(faBuilding, faCircle, faComments, faEnvelope, faEye, faFolderRegular, faQuestionCircle, faSquareRegular)

import {
  faAngleUp,
  faCheck,
  faChevronDown,
  faChevronLeft,
  faChevronRight,
  faCity,
  faCogs,
  faFastForward,
  faFlask,
  faFolder,
  faFolderOpen,
  faHammer,
  faHome,
  faLandmark,
  faLock,
  faMagic,
  faMapMarkerAlt,
  faMapPin,
  faMedal,
  faMinus,
  faMinusSquare,
  faParking,
  faPause,
  faPlay,
  faPlus,
  faPlusSquare,
  faPoll,
  faRedoAlt,
  faSatellite,
  faSearch,
  faSearchLocation,
  faSquare,
  faTimes,
  faToggleOff,
  faToggleOn,
  faTools,
  faUndoAlt,
  faUserSecret,
  faUserTie,
  faVolumeOff,
  faVolumeUp
} from '@fortawesome/free-solid-svg-icons'
library.add(faAngleUp, faCheck, faChevronDown, faChevronLeft, faChevronRight, faCity, faCogs, faFastForward, faFlask, faFolder, faFolderOpen, faHammer, faHome, faLandmark, faLock,
  faMagic, faMapMarkerAlt, faMapPin, faMedal, faMinus, faMinusSquare, faParking, faPause, faPlay, faPlus, faPlusSquare, faPoll, faRedoAlt, faSatellite,
  faSearch, faSearchLocation, faSquare, faTimes, faToggleOff, faToggleOn, faTools, faUndoAlt, faUserSecret, faUserTie, faVolumeOff, faVolumeUp)

import { faBimobject, faDiscord, faGithub, faMegaport, faMizuni, faMonero, faTwitter } from '@fortawesome/free-brands-svg-icons'
library.add(faBimobject, faDiscord, faGithub, faMegaport, faMizuni, faMonero, faTwitter)

import Vue from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

Vue.component('font-awesome-icon', FontAwesomeIcon)
