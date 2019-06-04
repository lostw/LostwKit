window.appInjection = (function() {
    var actions = [];
    var postMessage = function(message) {
       window.webkit.messageHandlers.appInjection.postMessage(message);
    };
    var postObj = function(obj) {
       postMessage(JSON.stringify(obj));
    };
   var reloadRightAction = function() {
       var titles = actions.map(function(item){
                                return item.name;
                                });
       postObj({"type": "rightAction", "actions": titles});
   };
                       
    return {
        version: "1.0",
        env: "iOS",
        postMessage: postMessage,
        registerRightAction: function(actionName, callback) {
            for (var i = 0; i < actions.length; i++) {
                if (actions[i].name === actionName) {
                    actions[i] = {"name": actionName, "callback": callback}
                    return;
                }
            }
            
            actions.push({"name": actionName, "callback": callback})
            reloadRightAction()
        },
        removeRightAction: function(actionName) {
            var length = actions.length
            if (actionName) {
                for (var i = 0; i < length; i++) {
                    if (actions[i].name === actionName) {
                        actions.splice(i, 1);
                        break;
                    }
                }
            } else {
                actions = []
            }
            
            if (actions.length != length) {
                reloadRightAction()
            }
        },
       executeRightAction: function(actionName) {
            for (var i = 0; i < actions.length; i++) {
                var item = actions[i];
                if (item.name === actionName) {
                    item.callback()
                    break;
                }
            }
       },
       
        openPage: function(pageName, params) {
            var json = {"type": "page", "page": pageName}
            if (params) {
                json["data"] = params
            }
            postMessage(json)
        }
    }
})()
