<template>
  <div>
    <el-table
      :data="proxies"
      :default-sort="{prop: 'name', order: 'ascending'}"
      :cell-class-name="getCellClass"
      style="width: 100%"
    >
      <el-table-column type="expand">
        <template slot-scope="props">
          <el-popover
            ref="popover4"
            placement="right"
            width="600"
            style="margin-left:0px"
            trigger="click"
          >
            <my-traffic-chart :proxy_name="props.row.name"></my-traffic-chart>
          </el-popover>

          <el-button
            v-popover:popover4
            type="primary"
            size="small"
            icon="view"
            :name="props.row.name"
            style="margin-bottom:10px"
            @click="fetchData2"
          >Traffic Statistics</el-button>

          <el-form label-position="left" inline class="demo-table-expand">
            <!-- <el-form-item label="Name">
              <span>{{ props.row.name }}</span>
            </el-form-item>-->
            <el-form-item label="Type">
              <span>{{ props.row.type }}</span>
            </el-form-item>
            <el-form-item label="Addr">
              <span>{{ props.row.addr }}</span>
            </el-form-item>
            <el-form-item label="Port">
              <span>{{ props.row.port }}</span>
            </el-form-item>
            <el-form-item label="ssh">
              <span>{{ props.row.ssh }}</span>
            </el-form-item>
            <el-form-item label="Encryption">
              <span>{{ props.row.encryption }}</span>
            </el-form-item>
            <el-form-item label="Compression">
              <span>{{ props.row.compression }}</span>
            </el-form-item>
            <el-form-item label="Last Start">
              <span>{{ props.row.last_start_time }}</span>
            </el-form-item>
            <el-form-item label="Last Close">
              <span>{{ props.row.last_close_time }}</span>
            </el-form-item>
          </el-form>
        </template>
      </el-table-column>
      <el-table-column label="Name" prop="name" sortable></el-table-column>
      <el-table-column label="Port" prop="port" sortable></el-table-column>
      <el-table-column label="Connections" prop="conns" sortable></el-table-column>
      <el-table-column label="Traffic In" prop="traffic_in" :formatter="formatTrafficIn" sortable></el-table-column>
      <el-table-column
        label="Traffic Out"
        prop="traffic_out"
        :formatter="formatTrafficOut"
        sortable
      ></el-table-column>
      <el-table-column label="status" prop="status" sortable>
        <template slot-scope="scope">
          <el-tag type="success" v-if="scope.row.status === 'online'">{{ scope.row.status }}</el-tag>
          <el-tag type="danger" v-else>{{ scope.row.status }}</el-tag>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script>
import Humanize from "humanize-plus";
import Traffic from "./Traffic.vue";
import { TcpProxy } from "../utils/proxy.js";
export default {
  data() {
    return {
      proxies: null
    };
  },
  created() {
    this.fetchData();
  },
  watch: {
    $route: "fetchData"
  },
  methods: {
    formatTrafficIn(row, column) {
      return Humanize.fileSize(row.traffic_in);
    },
    formatTrafficOut(row, column) {
      return Humanize.fileSize(row.traffic_out);
    },
    getCellClass({ row, column, columnIndex }) {
      // el-tag el-tag--info
      if (columnIndex == 3) {
        // ?? Connections
        if (row[column.property] > 20) {
          return "cell_danger";
        }
        if (row[column.property] > 10) {
          return "cell_warning";
        }
        if (row[column.property] > 0) {
          return "cell_normal";
        }
      }
      if (columnIndex == 5) {
        // ?? Traffic Out
        if (row[column.property] > 1e9) {
          return "cell_danger";
        }
        if (row[column.property] > 1e5) {
          return "cell_warning";
        }
        if (row[column.property] > 0) {
          return "cell_normal";
        }
      }
      return "";
    },
    fetchData() {
      fetch("/api/proxy/tcp", { credentials: "include" })
        .then(res => {
          return res.json();
        })
        .then(json => {
          // TODO 合并相同客户端的 proxy 和 ssh
          let _proxies = {};
          json.proxies.forEach(_proxyStats => {
            let _proxy = new TcpProxy(_proxyStats);
            if (!!_proxies[_proxy.IP]) {
              if (_proxy.name.indexOf("_ssh") == -1) {
                _proxies[_proxy.IP].name = _proxy.name;
                _proxies[_proxy.IP].port = _proxy.port;
              }
            } else {
              _proxies[_proxy.IP] = _proxy;
            }
            if (_proxy.name.indexOf("_ssh") > 0) {
              // ssh root@139.196.120.46 -p 23979
              _proxies[_proxy.IP].ssh =
                "ssh root@139.196.120.46 -p " + _proxy.port;
            }
          });
          // for (let _proxyStats of json.proxies) {
          //   let _proxy = new TcpProxy(_proxyStats);
          //   if (!!_proxies[_proxy.IP]) {
          //     if (_proxy.name.indexOf("_ssh") > 0) {
          //       // ssh root@139.196.120.46 -p 23979
          //       _proxies[_proxy.IP].ssh = `ssh root@139.196.120.46 -p ${_proxy.port}`;
          //     }
          //   } else {
          //     _proxies[_proxy.IP] = _proxy;
          //   }
          // }
          console.log(_proxies);

          this.proxies = new Array();
          Object.keys(_proxies).forEach(key => {
            this.proxies.push(_proxies[key]);
          });
          // for (let proxyStats of _proxies) {
          //   this.proxies.push(proxyStats);
          // }
          console.log(this.proxies);
        });
    }
  },
  components: {
    "my-traffic-chart": Traffic
  }
};
</script>

<style>
.cell_danger div {
  color: #f39;
  text-decoration: underline dotted;
}
.cell_warning div {
  color: #f93;
  text-decoration: underline dotted;
}
.cell_normal div {
  color: #39f;
  text-decoration: underline dotted;
}
.cell_success div {
  color: #393;
  text-decoration: underline dotted;
}

</style>
