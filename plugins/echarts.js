import Vue from 'vue'
import ECharts from 'vue-echarts/components/ECharts'

import 'echarts/lib/chart/graph'

import 'echarts/lib/component/axis'
import 'echarts/lib/component/grid'
import 'echarts/lib/component/tooltip'
import 'echarts/lib/component/title'
import 'echarts/lib/component/visualMap'

Vue.component('chart', ECharts)
