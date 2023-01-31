// Copyright (c) 2022, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import ballerina/log;

# Log Handler Class
public class LogHandler {
    private string context;

    public isolated  function init(string context) {
        self.context = context;
    }

    # Debug logger
    # + msg - debug message 
    public isolated function Debug(string msg) {
        log:printDebug(self.context + ": " + msg);
    }

    # Error logger
    # + msg - error message 
    public isolated function Error(string msg) {
        log:printError(self.context + ": " + msg);
    }

    # Info logger
    # + msg - info message 
    public isolated function Info(string msg) {
        log:printInfo(self.context + ": " + msg);
    }

    # Warn logger
    # + msg - warn message 
    public isolated function Warn(string msg) {
        log:printWarn(self.context + ": " + msg);
    }
}
