package proxy

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"regexp"
	"strings"
	"sync"

	"github.com/vanton/frp/client/event"
	"github.com/vanton/frp/models/config"
	"github.com/vanton/frp/models/msg"
	"github.com/vanton/frp/utils/log"
	frpNet "github.com/vanton/frp/utils/net"

	"github.com/fatedier/golib/errors"
)

type ProxyManager struct {
	sendCh  chan (msg.Message)
	proxies map[string]*ProxyWrapper

	closed bool
	mu     sync.RWMutex

	logPrefix string
	log.Logger
}

func NewProxyManager(msgSendCh chan (msg.Message), logPrefix string) *ProxyManager {
	return &ProxyManager{
		proxies:   make(map[string]*ProxyWrapper),
		sendCh:    msgSendCh,
		closed:    false,
		logPrefix: logPrefix,
		Logger:    log.NewPrefixLogger(logPrefix),
	}
}

func (pm *ProxyManager) StartProxy(name string, remoteAddr string, serverRespErr string) error {
	pm.mu.RLock()
	pxy, ok := pm.proxies[name]
	pm.mu.RUnlock()
	if !ok {
		return fmt.Errorf("proxy [%s] not found", name)
	}

	err := pxy.SetRunningStatus(remoteAddr, serverRespErr)
	if err != nil {
		return err
	}
	return nil
}

func (pm *ProxyManager) Close() {
	pm.mu.Lock()
	defer pm.mu.Unlock()
	for _, pxy := range pm.proxies {
		pxy.Stop()
	}
	pm.proxies = make(map[string]*ProxyWrapper)
}

func (pm *ProxyManager) HandleWorkConn(name string, workConn frpNet.Conn) {
	pm.mu.RLock()
	pw, ok := pm.proxies[name]
	pm.mu.RUnlock()
	if ok {
		pw.InWorkConn(workConn)
	} else {
		workConn.Close()
	}
}

func (pm *ProxyManager) HandleEvent(evType event.EventType, payload interface{}) error {
	var m msg.Message
	switch e := payload.(type) {
	case *event.StartProxyPayload:
		m = e.NewProxyMsg
	case *event.CloseProxyPayload:
		m = e.CloseProxyMsg
	default:
		return event.ErrPayloadType
	}

	err := errors.PanicToError(func() {
		pm.sendCh <- m
	})
	return err
}

func (pm *ProxyManager) GetAllProxyStatus() []*ProxyStatus {
	ps := make([]*ProxyStatus, 0)
	pm.mu.RLock()
	defer pm.mu.RUnlock()
	for _, pxy := range pm.proxies {
		ps = append(ps, pxy.GetStatus())
	}
	return ps
}

func (pm *ProxyManager) Reload(pxyCfgs map[string]config.ProxyConf) {
	pm.mu.Lock()
	defer pm.mu.Unlock()

	// NOTE 获取 city code
	city := pm.GetCity()
	fmt.Println("GetCity:", city)

	delPxyNames := make([]string, 0)
	for name, pxy := range pm.proxies {
		del := false
		cfg, ok := pxyCfgs[name]
		if !ok {
			del = true
		} else {
			if !pxy.Cfg.Compare(cfg) {
				del = true
			}
		}

		if del {
			delPxyNames = append(delPxyNames, name)
			delete(pm.proxies, name)

			pxy.Stop()
		}
	}
	if len(delPxyNames) > 0 {
		pm.Info("proxy removed: %v", delPxyNames)
	}

	addPxyNames := make([]string, 0)
	for name, cfg := range pxyCfgs {
		if _, ok := pm.proxies[name]; !ok {
			// NOTE 设置 city code
			city := pm.GetCity()
			// fmt.Println(city)
			cfg.SetCity(city)
			// fmt.Println(cfg)

			pxy := NewProxyWrapper(cfg, pm.HandleEvent, pm.logPrefix)
			pm.proxies[name] = pxy
			addPxyNames = append(addPxyNames, name)

			pxy.Start()
		}
	}
	if len(addPxyNames) > 0 {
		pm.Info("proxy added: %v", addPxyNames)
	}
}

func (pm *ProxyManager) GetCity() string {
	// NOTE 获取 city code
	res, err := http.Get("http://pv.sohu.com/cityjson?ie=utf-8")

	if err != nil {
		fmt.Println("Fatal error ", err.Error())
	}

	defer res.Body.Close()

	content, err := ioutil.ReadAll(res.Body)
	if err != nil {
		fmt.Println("Fatal error ", err.Error())
	}

	// fmt.Println(string(content))
	// NOTE 解析 content
	str := strings.ToLower(string(content))
	if strings.Index(str, "cid") > -1 {
		reg := regexp.MustCompile(`[\d]+`)
		citys := reg.FindAllString(strings.Split(str, "cid")[1], -1)
		// fmt.Println(citys)
		return citys[0]
	}
	return ""
}
