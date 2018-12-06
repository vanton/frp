import 'element-ui/lib/theme-chalk/index.css'
import 'whatwg-fetch'
import './utils/less/custom.less'

// import ElementUI from 'element-ui'
import {
    Button,
    Col,
    Form,
    FormItem,
    Menu,
    MenuItem,
    Popover,
    Row,
    Submenu,
    Table,
    TableColumn,
    Tag
} from 'element-ui'

import App from './App.vue'
import Vue from 'vue'
import lang from 'element-ui/lib/locale/lang/en'
import locale from 'element-ui/lib/locale'
import router from './router'

Vue.prototype.$ELEMENT = {
    size: 'small'
}

locale.use(lang)

Vue.use(Button)
Vue.use(Form)
Vue.use(FormItem)
Vue.use(Row)
Vue.use(Col)
Vue.use(Table)
Vue.use(TableColumn)
Vue.use(Popover)
Vue.use(Menu)
Vue.use(Submenu)
Vue.use(MenuItem)
Vue.use(Tag)

Vue.config.productionTip = false

new Vue({
    el: '#app',
    router,
    template: '<App/>',
    components: {
        App
    }
})
