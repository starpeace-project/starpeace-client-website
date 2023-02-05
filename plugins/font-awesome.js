import { library } from '@fortawesome/fontawesome-svg-core';

import * as far from '@fortawesome/free-regular-svg-icons';
import * as fas from '@fortawesome/free-solid-svg-icons';
import * as fab from '@fortawesome/free-brands-svg-icons';

library.add(far.faBuilding, far.faCircle, far.faComments, far.faEnvelope, far.faEye, far.faFolder, far.faQuestionCircle, far.faSquare);
library.add(fas.faAngleUp, fas.faCheck, fas.faChevronDown, fas.faChevronLeft, fas.faChevronRight, fas.faCity, fas.faCogs, fas.faFastForward, fas.faFlask,
  fas.faFolder, fas.faFolderOpen, fas.faHammer, fas.faHome, fas.faLandmark, fas.faLock, fas.faMagic, fas.faMapMarkerAlt, fas.faMapPin, fas.faMedal,
  fas.faMinus, fas.faMinusSquare, fas.faParking, fas.faPause, fas.faPlay, fas.faPlus, fas.faPlusSquare, fas.faPoll, fas.faRedoAlt, fas.faSatellite,
  fas.faSearch, fas.faSearchLocation, fas.faSquare, fas.faTimes, fas.faToggleOff, fas.faToggleOn, fas.faTools, fas.faUndoAlt, fas.faUserSecret,
  fas.faUserTie, fas.faVolumeOff, fas.faVolumeUp);
library.add(fab.faBimobject, fab.faDiscord, fab.faGithub, fab.faMegaport, fab.faMizuni, fab.faMonero);


import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome';

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.component('font-awesome-icon', FontAwesomeIcon);
});
