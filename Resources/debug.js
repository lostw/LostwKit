//ajax-hook.js https://github.com/wendux/Ajax-hook/
!function(t,e){for(var r in e)t[r]=e[r]}(window,function(t){function e(n){if(r[n])return r[n].exports;var o=r[n]={i:n,l:!1,exports:{}};return t[n].call(o.exports,o,o.exports,e),o.l=!0,o.exports}var r={};return e.m=t,e.c=r,e.i=function(t){return t},e.d=function(t,r,n){e.o(t,r)||Object.defineProperty(t,r,{configurable:!1,enumerable:!0,get:n})},e.n=function(t){var r=t&&t.__esModule?function(){return t.default}:function(){return t};return e.d(r,"a",r),r},e.o=function(t,e){return Object.prototype.hasOwnProperty.call(t,e)},e.p="",e(e.s=3)}([function(t,e,r){"use strict";function n(t,e){var r={};for(var n in t)r[n]=t[n];return r.target=r.currentTarget=e,r}function o(t){function e(e){return function(){var r=this.hasOwnProperty(e+"_")?this[e+"_"]:this.xhr[e],n=(t[e]||{}).getter;return n&&n(r,this)||r}}function r(e){return function(r){var o=this.xhr,i=this,s=t[e];if("on"===e.substring(0,2))i[e+"_"]=r,o[e]=function(s){s=n(s,i),t[e]&&t[e].call(i,o,s)||r.call(i,s)};else{var u=(s||{}).setter;r=u&&u(r,i)||r,this[e+"_"]=r;try{o[e]=r}catch(t){}}}}function o(e){return function(){var r=[].slice.call(arguments);if(t[e]){var n=t[e].call(this,r,this.xhr);if(n)return n}return this.xhr[e].apply(this.xhr,r)}}return window[u]=window[u]||XMLHttpRequest,XMLHttpRequest=function(){var t=new window[u];for(var n in t){var i="";try{i=s(t[n])}catch(t){}"function"===i?this[n]=o(n):Object.defineProperty(this,n,{get:e(n),set:r(n),enumerable:!0})}var a=this;t.getProxy=function(){return a},this.xhr=t},window[u]}function i(){window[u]&&(XMLHttpRequest=window[u]),window[u]=void 0}Object.defineProperty(e,"__esModule",{value:!0});var s="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(t){return typeof t}:function(t){return t&&"function"==typeof Symbol&&t.constructor===Symbol&&t!==Symbol.prototype?"symbol":typeof t};e.configEvent=n,e.hook=o,e.unHook=i;var u="_rxhr"},function(t,e,r){"use strict";function n(t){if(h)throw"Proxy already exists";return h=new f(t)}function o(){h=null,(0,d.unHook)()}function i(t){return t.replace(/^\s+|\s+$/g,"")}function s(t){return t.watcher||(t.watcher=document.createElement("a"))}function u(t,e){var r=t.getProxy(),n="on"+e+"_",o=(0,d.configEvent)({type:e},r);r[n]&&r[n](o),s(t).dispatchEvent(new Event(e,{bubbles:!1}))}function a(t){this.xhr=t,this.xhrProxy=t.getProxy()}function c(t){function e(t){a.call(this,t)}return e[b]=Object.create(a[b]),e[b].next=t,e}function f(t){function e(t,e){var r=new P(t);if(!f)return r.resolve();var n={response:e.response,status:e.status,statusText:e.statusText,config:t.config,headers:t.resHeader||t.getAllResponseHeaders().split("\r\n").reduce(function(t,e){if(""===e)return t;var r=e.split(":");return t[r.shift()]=i(r.join(":")),t},{})};f(n,r)}function r(t,e,r){var n=new H(t),o={config:t.config,error:r};h?h(o,n):n.next(o)}function n(){return!0}function o(t,e){return r(t,this,e),!0}function a(t,r){return 4===t.readyState&&0!==t.status?e(t,r):4!==t.readyState&&u(t,w),!0}var c=t.onRequest,f=t.onResponse,h=t.onError;return(0,d.hook)({onload:n,onloadend:n,onerror:o,ontimeout:o,onabort:o,onreadystatechange:function(t){return a(t,this)},open:function(t,e){var n=this,o=e.config={headers:{}};o.method=t[0],o.url=t[1],o.async=t[2],o.user=t[3],o.password=t[4],o.xhr=e;var i="on"+w;e[i]||(e[i]=function(){return a(e,n)});var s=function(t){r(e,n,(0,d.configEvent)(t,n))};if([x,y,g].forEach(function(t){var r="on"+t;e[r]||(e[r]=s)}),c)return!0},send:function(t,e){var r=e.config;if(r.withCredentials=e.withCredentials,r.body=t[0],c){var n=function(){c(r,new m(e))};return!1===r.async?n():setTimeout(n),!0}},setRequestHeader:function(t,e){return e.config.headers[t[0].toLowerCase()]=t[1],!0},addEventListener:function(t,e){var r=this;if(-1!==l.indexOf(t[0])){var n=t[1];return s(e).addEventListener(t[0],function(e){var o=(0,d.configEvent)(e,r);o.type=t[0],o.isTrusted=!0,n.call(r,o)}),!0}},getAllResponseHeaders:function(t,e){var r=e.resHeader;if(r){var n="";for(var o in r)n+=o+": "+r[o]+"\r\n";return n}},getResponseHeader:function(t,e){var r=e.resHeader;if(r)return r[(t[0]||"").toLowerCase()]}})}Object.defineProperty(e,"__esModule",{value:!0}),e.proxy=n,e.unProxy=o;var h,d=r(0),l=["load","loadend","timeout","error","readystatechange","abort"],v=l[0],p=l[1],y=l[2],x=l[3],w=l[4],g=l[5],b="prototype";a[b]=Object.create({resolve:function(t){var e=this.xhrProxy,r=this.xhr;e.readyState=4,r.resHeader=t.headers,e.response=e.responseText=t.response,e.statusText=t.statusText,e.status=t.status,u(r,w),u(r,v),u(r,p)},reject:function(t){this.xhrProxy.status=0,u(this.xhr,t.type),u(this.xhr,p)}});var m=c(function(t){var e=this.xhr;t=t||e.config,e.withCredentials=t.withCredentials,e.open(t.method,t.url,!1!==t.async,t.user,t.password);for(var r in t.headers)e.setRequestHeader(r,t.headers[r]);e.send(t.body)}),P=c(function(t){this.resolve(t)}),H=c(function(t){this.reject(t)})},,function(t,e,r){"use strict";Object.defineProperty(e,"__esModule",{value:!0}),e.ah=void 0;var n=r(0),o=r(1);e.ah={proxy:o.proxy,unProxy:o.unProxy,hook:n.hook,unHook:n.unHook}}]));

function randomString(length) {
   var result           = '';
   var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
   var charactersLength = characters.length;
   for ( var i = 0; i < length; i++ ) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
   }
   return result;
}

class JSBridge {
    constructor() {}
    postMessage(params) {
        this.setupWebViewJavascriptBridge(bridge => {
            bridge.callHandler('postMessage', params, function(data) { console.log(data) })
        })
    }
    logMessage(params) {
        this.setupWebViewJavascriptBridge(bridge => {
            bridge.callHandler('logMessage', params)
        })
    }
    logResponse(params) {
        this.setupWebViewJavascriptBridge(bridge => {
            bridge.callHandler('logResponse', params)
        })
    }
    setupWebViewJavascriptBridge(callback) {
        if (window.WebViewJavascriptBridge) {
            return callback(WebViewJavascriptBridge)
        }
        if (window.WVJBCallbacks) {
            return window.WVJBCallbacks.push(callback)
        }
        window.WVJBCallbacks = [callback]
        var WVJBIframe = document.createElement('iframe')
        WVJBIframe.style.display = 'none'
        WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__'
        document.documentElement.appendChild(WVJBIframe)
        setTimeout(function() {
                   document.documentElement.removeChild(WVJBIframe)
                   }, 0)
    }
}

(function() {
    var bridage = new JSBridge()
    var originConsoleLog = window.console.log
    window.console.log = function(...args) {
        var list = args.map(function(o) {
             if (Array.isArray(o)) {
                return JSON.stringify(o)
             } else if (typeof o === 'object') {
                 return JSON.stringify(o)
             } else {
                 return "" + o
             }
        })

        bridage.logMessage(list.join(" "))
        originConsoleLog.apply(this, args)
    }



    ah.proxy({
        onRequest: (config, handler) => {
            var identifier = randomString(16)
            config.identifier = identifier
            handler.next(config)
        },
        onError: (err, handler) => {
            console.log(err.type)
            handler.next(err)
        },
        //请求成功后进入
        onResponse: (response, handler) => {
            bridage.logResponse({
            identifier: response.config.identifier,
            url: response.config.url,
            method: response.config.method,
            requestBody: response.config.body,
            timeout: response.config.xhr.timeout / 1000,
            requestHeaders: response.config.headers,
            responseBody: response.response,
            status: response.status,
            responseHeaders: response.headers


            })
            handler.next(response)
        }
    })
})()
