// Copyright (c) 2022, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import healthcare.fhir.r4.api.metadata.constants;
import healthcare.fhir.r4.api.metadata.models;

# Issue handler
public class IssueHandler {
    private LogHandler logHandler;
    private models:Issue[] issues;

    public isolated function init(string context) {
        self.logHandler = new(context);
        self.issues = [];
    }

    # Issue getter
    # + return - issues array
    public isolated function getIssues() returns models:Issue[] {
        return self.issues;
    }

    # Record service errors
    # + serviceError - service error
    public isolated function addServiceError(models:ServiceError serviceError) {

        models:Issue newIssue = {
            severity: serviceError.severity,
            code: serviceError.code,
            details: {
                text: constants:INTERNAL_SERVER_ERROR
            },
            diagnostics: serviceError.message
        };

        self.issues.push(newIssue);

        match newIssue.severity {
            constants:WARNING => {
                self.logHandler.Warn(serviceError.err.message());
            }
            constants:INFORMATION => {
                self.logHandler.Info(serviceError.err.message());
            }
            _ => {
                self.logHandler.Error(serviceError.err.stackTrace().toString());
            }
        }
    }
}
