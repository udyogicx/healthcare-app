// Copyright (c) 2022, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.

import healthcare.fhir.r4.api.metadata.models;
import healthcare.fhir.r4.api.metadata.constants;

# method to build capability statement from system data
# + return - capabilitity statement json object
public isolated  function buildCapabilityStatement() returns json|error {

    do {
        models:Implementation implementation = {
            description: "WSO2 Open Healthcare",
            url: "https://localhost:9443"
        };

        models:CapabilityStatement capabilityStatement = {
            resourceType: constants:CAPABILITY_STATEMENT,
            status: "active",
            kind: "instance",
            fhirVersion: "4.0.1",
            date: "23/03/2022",
            implementation: implementation,
            format: [],
            patchFormat: [],
            rest: [],
            messaging: [],
            document: []
        };
        capabilityStatement.format.push("json");
        capabilityStatement.format.push("xml");

        string[]? capabilityStatementPatchformats = capabilityStatement.patchFormat;
        if capabilityStatementPatchformats is string[] {
            capabilityStatementPatchformats.push("application/json-patch+json");
        }

        models:Rest rest = {
            mode: "server",
            'resource: [],
            interaction: []
        };

        models:Extension extensionToken = {
            url: "token",
            "valueUrl": "https://localhost:9443/oauth2/token"
        };

        models:Extension extensionRevoke = {
            url: "revoke",
            "valueUrl": "https://localhost:9443/oauth2/revoke"
        };

        models:Extension extensionAuthorize = {
            url: "authorize",
            "valueUrl": "https://localhost:9443/oauth2/authorize"
        };

        models:Extension securityExtension = {
            url: "http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris",
            extension: []
        };
        
        anydata[]? extensions = securityExtension.extension;
        if extensions is anydata[] {
            extensions.push(extensionToken);
            extensions.push(extensionRevoke);
            extensions.push(extensionAuthorize);
        }

        models:Security security = {
            cors: true,
            extension: []
        };

        models:Extension[]? extension = security.extension;
        if extension is models:Extension[] {
            extension.push(securityExtension);
        }
        
        models:Coding securityCoding = {
            system: "http://terminology.hl7.org/CodeSystem/restful-security-service",
            code: "SMART-on-FHIR",
            display: "SMART-on-FHIR"
        };

        models:CodeableConcept securityService = {
            text: "Service text",
            coding: [securityCoding]
        };

        security.'service = securityService;

        rest.security = security;

        models:Resource fhirResource = {
            'type: "MedicationKnowledge",
            supportedProfile: ["http://hl7.org/fhir/us/Davinci-drug-formulary/StructureDefinition/usdf-FormularyDrug"],
            interaction: [],
            searchParam: [],
            operation: []
        };

        models:Interaction interactionUpdate = {
            code: constants:update
        };

        models:Interaction interactionDelete = {
            code: constants:delete
        };

        models:Interaction interactionHistoryType = {
            code: constants:history_type
        };

        models:Interaction[]? interactions = fhirResource.interaction;
        if interactions is models:Interaction[] {
            interactions.push(interactionUpdate);
            interactions.push(interactionDelete);
            interactions.push(interactionHistoryType);
        }

        fhirResource.versioning = "versioned";
        fhirResource.conditionalCreate = false;
        fhirResource.conditionalRead = "not-supported";
        fhirResource.conditionalUpdate = false;
        fhirResource.conditionalDelete = "not-supported";
        fhirResource.referencePolicy = ["resolves"];
        fhirResource.searchRevInclude = ["null"];

        models:SearchParam searchParamDrugTier = {
            name: "DrugTier",
            'type: constants:STRING
        };

        models:SearchParam searchParamDrugPlan = {
            name: "DrugPlan",
            'type: constants:STRING
        };

        models:SearchParam searchParamDrugName = {
            name: "DrugName",
            'type: constants:STRING
        };

        models:SearchParam searchParamLastUpdated = {
            name: "_lastUpdated",
            'type: constants:STRING
        };

        models:SearchParam searchParamSecurity = {
            name: "_security",
            'type: constants:STRING
        };

        models:SearchParam[]? searchParams = fhirResource.searchParam;
        if searchParams is models:SearchParam[] {
            searchParams.push(searchParamDrugTier);
            searchParams.push(searchParamDrugPlan);
            searchParams.push(searchParamDrugName);
            searchParams.push(searchParamLastUpdated);
            searchParams.push(searchParamSecurity);
        }

        models:Operation operation = {
            name: "GET",
            definition: "Get data operation"
        };

        models:Operation[]? operations = fhirResource.operation;
        if operations is models:Operation[] {
            operations.push(operation);
        }

        models:Resource[]? resources = rest.'resource;
        if resources is models:Resource[] {
            resources.push(fhirResource);
        }

        models:Interaction interactionSearchSystem = {
            code: constants:SEARCH_SYSTEM
        };
        
        models:Interaction[]? interactionsRest = rest.interaction;
        if interactionsRest is models:Interaction[] {
            interactionsRest.push(interactionSearchSystem);
        }

        models:Rest[]? rests = capabilityStatement?.rest;
        if rests is models:Rest[] {
            rests.push(rest);
        }

        models:Messaging messaging = {
            endpoint: {
                protocol: constants:HTTP,
                address: "http://localhost:9090"
            },
            reliableCache: 5,
            supportedMessage: {
                mode: constants:Sender,
                definition: "This message is from sender"
            },
            documentation: "This is documentation"
        };

        models:Messaging[]? messagings = capabilityStatement.messaging;
        if messagings is models:Messaging[] {
            messagings.push(messaging);
        }

        models:Document document = {
            mode: constants:Producer,
            documentation: "This a documentation",
            profile: "http://localhost:9090/profile"
        };

        models:Document[]? documents = capabilityStatement.document;
        if documents is models:Document[] {
            documents.push(document);
        }

        return capabilityStatement.toJson();
    }on fail var err {
        return err;
    }
}   
