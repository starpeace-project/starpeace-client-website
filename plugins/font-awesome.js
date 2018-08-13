import { library } from '@fortawesome/fontawesome-svg-core'
import {
  faBuilding,
  faComments,
  faEnvelope,
  faEye,
  faQuestionCircle
} from '@fortawesome/free-regular-svg-icons'
import {
  faAngleUp,
  faCheck,
  faCogs,
  faFastForward,
  faGlobe,
  faMapPin,
  faMinus,
  faPause,
  faPlay,
  faPlus,
  faRedoAlt,
  faTimes,
  faToggleOff,
  faToggleOn,
  faUndoAlt,
  faUserSecret,
  faUserTie,
  faVolumeOff,
  faVolumeUp
} from '@fortawesome/free-solid-svg-icons'
import { faDiscord, faGithub, faTwitter } from '@fortawesome/free-brands-svg-icons'

library.add(faAngleUp, faBuilding, faCheck, faCogs, faComments, faDiscord, faEnvelope, faEye, faFastForward,
  faGithub, faGlobe, faMapPin, faMinus, faPause, faPlay, faPlus, faRedoAlt, faTimes, faToggleOff, faToggleOn,
  faUndoAlt, faQuestionCircle, faTwitter, faUserSecret, faUserTie, faVolumeOff, faVolumeUp)


import Vue from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

Vue.component('font-awesome-icon', FontAwesomeIcon)
