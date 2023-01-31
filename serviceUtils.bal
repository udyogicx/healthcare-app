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
import healthcare.fhir.r4.api.metadata.handlers;
import healthcare.fhir.r4.api.metadata.models;
import ballerina/http;

# Generator function for Operation Outcome resource
# + issueHandler - Issue handler for issues
# + return - Operation Outcome resource
public isolated function generateOperationOutcomeResource(handlers:IssueHandler issueHandler) returns models:OperationOutcome {
    handlers:LogHandler logHandler = new("OperationOutcomeGenerator");
    logHandler.Debug("Generating operation outcome started");

    if issueHandler.getIssues() == [] {
        issueHandler.addServiceError(createServiceError(constants:WARNING, constants:NOT_FOUND, (error(constants:NO_ISSUES_OP_OUTCOME))));
    }

    models:OperationOutcome operationOutcome = {
        resourceType: constants:OPERATION_OUTCOME,
        issue: []
    };

    logHandler.Debug("Populating operation outcome");
    
    foreach models:Issue issue in issueHandler.getIssues() {
        operationOutcome.issue.push(issue);
    }
    
    logHandler.Debug("Generating operation outcome ended");
    return operationOutcome;
}

# Method to handle service errors
#
# + issueHandler - Parameter Description
# + return - internal server error  occured
public isolated function handleServiceErrors(handlers:IssueHandler issueHandler) returns http:InternalServerError {
    models:OperationOutcome operationOutcome = generateOperationOutcomeResource(issueHandler);
    http:InternalServerError errorMessage = {
        mediaType: "application/fhir+json",
        body: operationOutcome
    }; 
    return errorMessage;
}

# Creates service error
# + severity - service error severity  
# + code - service error code  
# + err - error  
# + message - service error message
# + return - service error
public isolated function createServiceError(constants:IssueSeverity severity, constants:IssueType code, error err, string message = constants:CONTACT_SERVER_ADMIN) returns models:ServiceError {
    models:ServiceError serviceError = {
        severity: severity, 
        code: code,
        message: message,
        err:err
    };
    return serviceError;
}

# send fhir response method
#
# + payload - json payload
# + return - fhir+json response
public isolated function handleSuccessResponse(anydata payload) returns http:Ok {
    http:Ok reponse = {
        mediaType: "application/fhir+json",
        body: payload
    };
    return reponse;
}
