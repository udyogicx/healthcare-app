// Copyright (c) 2022, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import healthcare.fhir.r4.api.metadata.config;
import healthcare.fhir.r4.api.metadata.constants;
import healthcare.fhir.r4.api.metadata.handlers;
import healthcare.fhir.r4.api.metadata.models;
import ballerina/io;

## metadata of server and rest components as configurables
configurable config:ServerInfo server_info = ?;
configurable config:Security security = ?;

// TODO: uncomment below line when Choreo supports object arrays in configurable editor. 
// configurable config:Resource[] resources = ?;

 # generator class for capability statement
 public class CapabilityStatementGenerator {
    handlers:LogHandler logHandler;
    handlers:IssueHandler issueHandler;
    string resourcePath;
    
    public isolated function init(string resourcePath) {
        self.issueHandler = new("CapabilityStatementGenerator");
        self.logHandler = new("CapabilityStatementGenerator");
        self.logHandler.Debug("Generating capability statement initialized");
        self.resourcePath = resourcePath;

        json serverInfoConfig = server_info.toJson();
        io:println(serverInfoConfig);

        json securityCOnfig = security.toJson();
        io:println(securityCOnfig);
    }

    # method to build capability statement from metadata configurables
    # + return - capabilitity statement json object
    isolated function generate() returns models:CapabilityStatement|error {
        self.logHandler.Debug("Generating capability statement started");

        models:Implementation implementation = {
            description: server_info.implementation_description
        };

        string? implementationURL = server_info.implementation_url;

        if implementationURL is string {
            implementation.url = implementationURL;
        }

        models:CapabilityStatement capabilityStatement = {
            resourceType: constants:CAPABILITY_STATEMENT,
            status: server_info.status,
            date: server_info.date,
            kind: server_info.kind,
            implementation: implementation,
            fhirVersion: server_info.fhir_version,
            format: server_info.format,
            rest: []
        };

        string[]? patchFormats = server_info.patch_format;

        if patchFormats is string[] {
            capabilityStatement.patchFormat = patchFormats;
        }

        models:Coding seviceCoding = {
            system: constants:SERVICE_SYSTEM,
            code: constants:SERVICE_CODE,
            display: constants:SERVICE_DISPLAY
        };

        models:CodeableConcept securityService = {
            coding: [seviceCoding]
        };

        models:Extension tokenExtension = {
            url: constants:SECURITY_TOKEN,
            [constants:SECURITY_EXT_VALUEURL]: security.token_url
        };

        models:Extension revokeExtension = {
            url: constants:SECURITY_REVOKE,
            [constants:SECURITY_EXT_VALUEURL]: security.revoke_url
        };

        models:Extension authorizeExtension = {
            url: constants:SECURITY_AUTHORIZE,
            [constants:SECURITY_EXT_VALUEURL]: security.authorize_url
        };

        models:Extension securityExtension = {
            url: constants:SECURITY_EXT_URL,
            extension: []
        };

        anydata[]? subExtensions = securityExtension.extension;
        if subExtensions is anydata[] {
            subExtensions.push(tokenExtension);
            subExtensions.push(revokeExtension);
            subExtensions.push(authorizeExtension);
        }

        models:Security restSecurity = {
            cors: false,
            extension: []
        };

        boolean? cors = security["cors"];
        if cors is boolean {
            restSecurity.cors = cors;
        } else {
            self.logHandler.Debug(constants:NO_CORS);
        }

        restSecurity.'service = securityService;
        
        models:Extension[]? securityExtensions = restSecurity.extension;
        if securityExtensions is models:Extension[] {
            securityExtensions.push(securityExtension);
        }

        models:Rest rest = {
            mode: constants:REST_MODE_SERVER,
            security: restSecurity,
            'resource: []
        };

        self.logHandler.Debug("Populating resources");
        // TODO - Remove lines (128-136) when Choreo supports object arrays in configurable editor. 
        // Refer Issue: https://github.com/wso2-enterprise/open-healthcare/issues/847
        config:Resource[] resources = [];
        do {
            json resourcesJSON = check io:fileReadJson(self.resourcePath);
            resources = check resourcesJSON.cloneWithType();
        } on fail var err {
            self.logHandler.Debug("Populating resources failed");
            self.issueHandler.addServiceError(createServiceError(constants:ERROR, constants:NOT_FOUND, err));
        }
        //

        if resources.length() > 0 {
            foreach config:Resource resourceConfig in resources {

                models:Resource 'resource = {
                    'type: resourceConfig.'type
                };

                string[]? supportedProfile = resourceConfig.supportedProfiles;
                if supportedProfile is string[] {
                    'resource.supportedProfile = supportedProfile;
                } else {
                    self.logHandler.Debug(constants:NO_SUPPORTED_PROFILE);
                }

                'resource.interaction = [];
                models:Interaction[]? resourceInteractions = 'resource.interaction;
                string[]? interactions = resourceConfig.interactions;
                if interactions is string[] {
                    if resourceInteractions is models:Interaction[] {
                        foreach string interactionCode in interactions {    
                            models:Interaction interaction = {
                                code: interactionCode
                            };
                            resourceInteractions.push(interaction);
                        }
                    }else {
                        self.logHandler.Debug(constants:NO_RESOURCE_INTERACTION);
                    }
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_INTERACTION);
                }

                string? versioning = resourceConfig.versioning;
                if versioning is string {
                    'resource.versioning = versioning;
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_VERSIONING);
                }

                boolean? conditionalCreate = resourceConfig.conditionalCreate;
                if conditionalCreate is boolean {
                    'resource.conditionalCreate = conditionalCreate;
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_CONDITIONAL_CREATE);
                }

                string? conditionalRead = resourceConfig.conditionalRead;
                if conditionalRead is string {
                    'resource.conditionalRead = conditionalRead;
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_CONDITIONAL_READ);
                }

                boolean? conditionalUpdate = resourceConfig.conditionalUpdate;
                if conditionalUpdate is boolean {
                    'resource.conditionalUpdate = conditionalUpdate;
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_CONDITIONAL_UPDATE);
                }

                string? conditionalDelete = resourceConfig.conditionalDelete;
                if conditionalDelete is string {
                    'resource.conditionalDelete = conditionalDelete;
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_CONDITIONAL_DELETE);
                }

                string[]? referencePolicies = 'resource.referencePolicy;
                string[]? referencePoliciesConfig = resourceConfig.referencePolicies;
                if referencePoliciesConfig is string[] {
                    if referencePolicies is string[] {
                        foreach string referencePolicy in referencePolicies {    
                            referencePolicies.push(referencePolicy);
                        }
                    } else {
                        self.logHandler.Debug(constants:NO_RESOURCE_REFERENCE_POLICIES);
                    }
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_REFERENCE_POLICIES);
                }

                string[]? searchRevIncludes = 'resource.searchRevInclude;
                string[]? searchRevIncludesConfig = resourceConfig.searchRevIncludes;
                if searchRevIncludesConfig is string[] {
                    if searchRevIncludes is string[] {
                        foreach string searchRevInclude in searchRevIncludesConfig {    
                            searchRevIncludes.push(searchRevInclude);
                        }
                    } else {
                        self.logHandler.Debug(constants:NO_RESOURCE_SEARCHREV_INCLUDE);
                    }
                } else {
                    self.logHandler.Debug(constants:NO_RESOURCE_SEARCHREV_INCLUDE);
                }

                'resource.searchParam = [];
                models:SearchParam[]? resourceSearchParams = 'resource.searchParam;
                string[]? searchParamsConfig = resourceConfig.searchParamString;
                self.setSearchParam(resourceSearchParams, searchParamsConfig, constants:STRING);

                searchParamsConfig = resourceConfig.searchParamNumber;
                self.setSearchParam(resourceSearchParams, searchParamsConfig, constants:NUMBER);

                searchParamsConfig = resourceConfig.searchParamToken;
                self.setSearchParam(resourceSearchParams, searchParamsConfig, constants:TOKEN);

                searchParamsConfig = resourceConfig.searchParamDate;
                self.setSearchParam(resourceSearchParams, searchParamsConfig, constants:DATE);

                rest.interaction = [];
                models:Interaction[]? restInteractions = rest.interaction;
                string[]? restInteractionsConfig = server_info.interactions;
                if restInteractionsConfig is string[] {
                    if restInteractions is models:Interaction[] {
                        foreach string interactionCode in restInteractionsConfig {    
                            models:Interaction interaction = {
                                code: interactionCode
                            };
                            restInteractions.push(interaction);
                        }
                    } else {
                        self.logHandler.Debug(constants:NO_REST_INTERACTIONS);
                    }
                } else {
                    self.logHandler.Debug(constants:NO_REST_INTERACTIONS);
                }

                models:Resource[]? restResources = rest.'resource;
                if restResources is models:Resource[] {
                    restResources.push('resource);
                }

                models:Rest[]? rests = capabilityStatement.rest;
                if rests is models:Rest[] {
                    rests.push(rest);
                }
            }
        } else {
            self.logHandler.Debug(constants:NO_FHIR_RESOURCES);
        }

        if self.issueHandler.getIssues().length() > 0 {
            models:Issue[] fatalIssues = from models:Issue issue in self.issueHandler.getIssues()
                where issue.severity == constants:ERROR || issue.severity == constants:EXCEPTION
                select issue;

            if fatalIssues.length() > 0 {
                self.logHandler.Debug("Generating capability statement failed");
                return error(constants:CAPABILITY_STATEMENT_FAILED);
            }
        }

        self.logHandler.Debug("Generating capability statement ended");
        return capabilityStatement;
    }

    # Set search param method
    #
    # + resourceSearchParamsRef - resource search params reference 
    # + params - search params  
    # + 'type - search params type
    isolated function setSearchParam(models:SearchParam[]? resourceSearchParamsRef, string[]? params, string 'type) {
        string[]? searchParamsConfig = params;
        if searchParamsConfig is string[] {
            if resourceSearchParamsRef is models:SearchParam[] {
                foreach string searchParamString in searchParamsConfig {    
                    models:SearchParam searchParam = {
                        name: searchParamString,
                        'type: 'type.toString()
                    };
                    resourceSearchParamsRef.push(searchParam);
                }
            } else {
                self.logHandler.Debug(constants:NO_SEARCH_PARAMS + ": " + 'type);
            }
        } else {
            self.logHandler.Debug(constants:NO_SEARCH_PARAMS + ": " + 'type);
        }
    }
}
