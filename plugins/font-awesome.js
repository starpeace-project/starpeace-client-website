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
  faGlobe,
  faMapPin,
  faMinus,
  faPlus,
  faRedoAlt,
  faTimes,
  faToggleOff,
  faToggleOn,
  faUndoAlt,
  faUserSecret,
  faUserTie
} from '@fortawesome/free-solid-svg-icons'
import { faDiscord, faGithub } from '@fortawesome/free-brands-svg-icons'

library.add(faAngleUp, faBuilding, faCheck, faCogs, faComments, faEnvelope, faEye,
  faGlobe, faMapPin, faMinus, faPlus, faRedoAlt, faTimes, faToggleOff, faToggleOn,
  faUndoAlt, faQuestionCircle, faUserSecret, faUserTie, faDiscord, faGithub)


import Vue from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

Vue.component('font-awesome-icon', FontAwesomeIcon)
