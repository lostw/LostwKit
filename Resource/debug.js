//ajax-hook.js https://github.com/wendux/Ajax-hook/
!function(t){function n(e){if(r[e])return r[e].exports;var i=r[e]={exports:{},id:e,loaded:!1};return t[e].call(i.exports,i,i.exports,n),i.loaded=!0,i.exports}var r={};return n.m=t,n.c=r,n.p="",n(0)}([function(t,n,r){r(1)(window)},function(t,n){t.exports=function(t){var n="RealXMLHttpRequest";t.hookAjax=function(t){function r(n){return function(){var r=this.hasOwnProperty(n+"_")?this[n+"_"]:this.xhr[n],e=(t[n]||{}).getter;return e&&e(r,this)||r}}function e(n){return function(r){var e=this.xhr,i=this,o=t[n];if("function"==typeof o)e[n]=function(){t[n](i)||r.apply(e,arguments)};else{var u=(o||{}).setter;r=u&&u(r,i)||r;try{e[n]=r}catch(t){this[n+"_"]=r}}}}function i(n){return function(){var r=[].slice.call(arguments);if(!t[n]||!t[n].call(this,r,this.xhr))return this.xhr[n].apply(this.xhr,r)}}return window[n]=window[n]||XMLHttpRequest,XMLHttpRequest=function(){var t=new window[n];for(var o in t){var u="";try{u=typeof t[o]}catch(t){}"function"===u?this[o]=i(o):Object.defineProperty(this,o,{get:r(o),set:e(o),enumerable:!0})}this.xhr=t},window[n]},t.unHookAjax=function(){window[n]&&(XMLHttpRequest=window[n]),window[n]=void 0},t.default=t}}]);


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
})()
