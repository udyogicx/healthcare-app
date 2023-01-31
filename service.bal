// Copyright (c) 2022, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import healthcare.fhir.r4.api.metadata.handlers;
import healthcare.fhir.r4.api.metadata.models;
import healthcare.fhir.r4.api.metadata.constants;
import ballerina/http;
import ballerina/time;

# # The service representing capability statement API
CapabilityStatementGenerator capabilityStatementGenerator = new("./resources/resources.json");
final readonly & models:CapabilityStatement capabilityStatement = check capabilityStatementGenerator.generate().cloneReadOnly();

service class ServiceErrorInterceptor {
    *http:ResponseErrorInterceptor;
    remote function interceptResponseError(error err) returns http:InternalServerError {
        handlers:IssueHandler issueHandler = new("Service");
        issueHandler.addServiceError(createServiceError(constants:FATAL, constants:PROCESSING, err, constants:INTERNAL_SERVER_ERROR));
        return handleServiceErrors(issueHandler);
    }
}

# Service response error interceptor
ServiceErrorInterceptor serviceErrorInterceptor = new();

# The service representing well known API
# Bound to port defined by configs
@http:ServiceConfig{
   interceptors: [serviceErrorInterceptor]
}

service / on new http:Listener(9090) {
    # The capability statement is a key part of the overall conformance framework in FHIR. It is used as a statement of the
    # features of actual software, or of a set of rules for an application to provide. This statement connects to all the
    # detailed statements of functionality, such as StructureDefinitions and ValueSets. This composite statement of application
    # capability may be used for system compatibility testing, code generation, or as the basis for a conformance assessment.
    # For further information https://hl7.org/fhir/capabilitystatement.html
    # + return - capability statement as a json
    isolated resource function get fhir/r4/metadata() returns http:Ok|http:InternalServerError {
        handlers:IssueHandler issueHandler = new("Service");
        handlers:LogHandler logHandler = new("Service");

        json|error response = capabilityStatement.toJson();

        if(response is json) {
            logHandler.Debug("Capability statement served at " + time:utcNow()[0].toString());
            return handleSuccessResponse(response);
        } else {
            issueHandler.addServiceError(createServiceError(constants:FATAL, constants:PROCESSING, response, constants:INTERNAL_SERVER_ERROR));
            return handleServiceErrors(issueHandler);
        }
    }
}
