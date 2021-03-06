// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

# Bigquery Endpoint object.
# + bigqueryClient - Bigquery Connector client
public type Client client object {

    public http:Client bigqueryClient;

    public function __init(BigqueryConfiguration bigqueryConfig) {
        self.init(bigqueryConfig);
        self.bigqueryClient = new(BASE_URL, config = bigqueryConfig.clientConfig);
    }

    # Initialize Bigquery endpoint.
    #
    # + bigqueryConfig - Bigquery configuraion
    public function init(BigqueryConfiguration bigqueryConfig);

    # Lists all projects to which current user have been granted any project role.
    #
    # + nextPageToken - Page token, returned by a previous call, to request the next page of results.
    # + return - ProjectList object on success and error on failure
    public remote function listProjects(string nextPageToken = "") returns ProjectList|error;

    # Returns the dataset specified by datasetID.
    #
    # + projectId - Project ID of the requested dataset.
    # + datasetId - Dataset ID of the requested dataset.
    # + return - Dataset object on success and error on failure
    public remote function getDataset(string projectId, string datasetId) returns Dataset|error;

    #  Lists all datasets in the specified project to which user have been granted the READER dataset role.
    #
    # + projectId - Project ID of the requested dataset.
    # + nextPageToken - Page token, returned by a previous call, to request the next page of results.
    # + return - DatasetList object on success and error on failure
    public remote function listDatasets(string projectId, string nextPageToken = "") returns DatasetList|error;

    #  Lists all tables in the specified dataset.
    #
    # + projectId - Project ID of the requested dataset.
    # + datasetId - Dataset ID of the table to read.
    # + nextPageToken - Page token, returned by a previous call, to request the next page of results.
    # + return - TableList object on success and error on failure
    public remote function listTables(string projectId, string datasetId, string nextPageToken = "") returns TableList|
                                                                                                                 error;
    #  Gets the specified table resource by table ID.
    #
    # + projectId - Project ID of the requested dataset.
    # + datasetId - Dataset ID of the table to read.
    # + tableId - Table ID of the table to read.
    # + selectedFields - List of fields to return.
    # + return - TableList object on success and error on failure
    public remote function getTable(string projectId, string datasetId, string tableId, string... selectedFields)
                               returns Table|error;

    #  Retrieves table data from a specified set of rows.
    #
    # + projectId - Project ID of the requested dataset.
    # + datasetId - Dataset ID of the table to read.
    # + tableId - Table ID of the table to read.
    # + nextPageToken - Page token, returned by a previous call, to request the next page of results.
    # + selectedFields - List of fields to return.
    # + return - TableData object on success and error on failure
    public remote function listTableData(string projectId, string datasetId, string tableId, string nextPageToken = "",
                                         string... selectedFields) returns @tainted TableData|error;

    #  Streams data into BigQuery one record at a time without needing to run a load job.
    #
    # + projectId - Project ID of the new table.
    # + datasetId - Dataset ID of the new table.
    # + rows - The rows to insert.vious call, to request the next page of results.
    # + return - nill on success and error on failure
    public remote function insertAllTableData(string projectId, string datasetId, string tableId,
                                              InsertRequestData[] rows) returns error? ;

    #  Runs a BigQuery SQL query and returns results if the query completes within a specified timeout.
    #
    # + projectId - Project ID of the requested dataset.
    # + queryString - The query string of the query to execute which is following the BigQuery query syntax.
    # + queryParameters - Query parameters for Standard SQL queries.
    # + parameterMode - Query parameters for Standard SQL queries.
    # + return - QueryResults object on success and error on failure
    public remote function runQuery(string projectId, @sensitive string queryString, json queryParameters = (),
                                    ParameterMode parameterMode = "POSITIONAL") returns @tainted QueryResults|error;

    #  Retrieves the results of a query job.
    #
    # + projectId - Project ID of the requested dataset.
    # + jobId - Job ID of the query job.
    # + nextPageToken - Page token, returned by a previous call, to request the next page of results.
    # + return - QueryResults object on success and error on failure
    public remote function getQueryResults(string projectId, string jobId, string nextPageToken = "")
                               returns @tainted QueryResults|error;

    # Sign the given input jwt data.
    #
    # + data - Original that need to sign.
    # + algorithm - Signature string.
    # + keyStore - Keystore.
    # + return - Signature. Signed string.
    extern function sign(string data, string algorithm, KeyStore keyStore) returns (string);
};

public remote function Client.listProjects(string nextPageToken = "") returns ProjectList|error {
    string listProjectsPath = PROJECTS_PATH;
    if (nextPageToken != "") {
        listProjectsPath = listProjectsPath + QUESTION_MARK + PAGE_TOKEN_PATH + nextPageToken;
    }
    var httpResponse = self.bigqueryClient->get(listProjectsPath);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                ProjectList projectsList = convertToProjectsList(jsonResponse);
                return projectsList;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.getDataset(string projectId, string datasetId) returns Dataset|error {
    string getDatasetPath = PROJECTS_PATH + SLASH + projectId + DATASETS_PATH + SLASH + datasetId;
    var httpResponse = self.bigqueryClient->get(getDatasetPath);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                Dataset dataset = convertToDataset(jsonResponse);
                return dataset;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.listDatasets(string projectId, string nextPageToken = "") returns DatasetList|error {
    string listDatasetPath = PROJECTS_PATH + SLASH + projectId + DATASETS_PATH;
    if (nextPageToken != "") {
        listDatasetPath = listDatasetPath + QUESTION_MARK + PAGE_TOKEN_PATH +  nextPageToken;
    }
    var httpResponse = self.bigqueryClient->get(listDatasetPath);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                DatasetList datasetList = convertToDatasetList(jsonResponse);
                return datasetList;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.listTables(string projectId, string datasetId, string nextPageToken = "") returns TableList|error
{
    string listTablesPath = PROJECTS_PATH + SLASH + projectId + DATASETS_PATH;
    if (nextPageToken != "") {
        listTablesPath = listTablesPath + QUESTION_MARK + PAGE_TOKEN_PATH +  nextPageToken;
    }
    var httpResponse = self.bigqueryClient->get(listTablesPath);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                TableList tableList = convertToTableList(jsonResponse);
                return tableList;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.getTable(string projectId, string datasetId, string tableId, string... selectedFields) returns
                                                                                                              Table|
                                                                                                              error {
    string getTablePath = PROJECTS_PATH + SLASH + projectId + DATASETS_PATH + SLASH + datasetId + TABLES_PATH
        + SLASH + tableId;
    string uriParams = "";
    int index = 0;
    foreach string field in selectedFields {
        if (index == 0) {
            uriParams = field;
        } else {
            uriParams = uriParams + "," + field;
        }
        index = index + 1;
    }
    if (uriParams != "") {
        getTablePath = getTablePath + QUESTION_MARK + FIELDS_PATH +  uriParams;
    }
    var httpResponse = self.bigqueryClient->get(getTablePath);
    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                Table tableRes = convertToTable(jsonResponse);
                return tableRes;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.listTableData(string projectId, string datasetId, string tableId, string nextPageToken = "",
                                     string... selectedFields) returns @tainted TableData|error {
    string listTableDataPath = PROJECTS_PATH + SLASH + projectId + DATASETS_PATH + SLASH + datasetId + TABLES_PATH
        + SLASH + tableId + DATA_PATH;
    string uriParams = "";
    if (nextPageToken != "") {
        uriParams = uriParams + AND_SIGN + PAGE_TOKEN_PATH +  nextPageToken;
    }
    int index = 0;
    string fields = "";
    foreach string field in selectedFields {
        if (index == 0) {
            fields = field;
        } else {
            fields = fields + "," + field;
        }
        index = index + 1;
    }
    if (fields != "") {
        uriParams = uriParams + AND_SIGN + FIELDS_PATH +  fields;
    }
    if (uriParams != "") {
        listTableDataPath = listTableDataPath + "?" +  uriParams.substring(1,uriParams.length());
    }

    var httpResponse = self.bigqueryClient->get(untaint listTableDataPath);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                TableData tableData = convertToTableData(jsonResponse);
                return tableData;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.insertAllTableData(string projectId, string datasetId, string tableId, InsertRequestData[] rows)
                    returns error? {
    http:Request request = new;
    string insertDataPath = PROJECTS_PATH + SLASH + projectId + DATASETS_PATH + SLASH + datasetId + TABLES_PATH + SLASH
     + tableId + INSERT_PATH;
    json jsonPayload = { "kind": "bigquery#tableDataInsertAllRequest" };
    json[] jsonRows = [];
    int i = 0;
    foreach InsertRequestData row in rows {
        json jsonRow = {};
        jsonRow["json"] = row.jsonData;
        if (row.insertId != "") {
            jsonRow.insertId = row.insertId;
        }
        jsonRows[i] = jsonRow;
        i = i + 1;
    }
    jsonPayload.rows = jsonRows;
    request.setJsonPayload(untaint jsonPayload);
    var httpResponse = self.bigqueryClient->post(insertDataPath, request);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                return ();
            } else {
                return setInsertResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.runQuery(string projectId, @sensitive string queryString, json queryParameters = (),
                                ParameterMode parameterMode = "POSITIONAL")
                    returns @tainted QueryResults|error {
    http:Request request = new;
    string getQueryResultsPath = PROJECTS_PATH + SLASH + projectId + QUERIES_PATH;
    json jsonPayload = { "kind": "bigquery#queryRequest", "query" : queryString };
    if (queryParameters != ()) {
        jsonPayload.queryParameters = queryParameters;
        jsonPayload.useLegacySql = false;
        if (parameterMode == NAMED_MODE) {
            jsonPayload.parameterMode = NAMED_MODE;
        } else if (parameterMode == POSITIONAL_MODE) {
            jsonPayload.parameterMode = POSITIONAL_MODE;
        }
    }
    request.setJsonPayload(untaint jsonPayload);
    var httpResponse = self.bigqueryClient->post(getQueryResultsPath, request);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                QueryResults queryResults = convertToQueryResults(jsonResponse);
                return queryResults;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public remote function Client.getQueryResults(string projectId, string jobId, string nextPageToken = "")
                           returns @tainted QueryResults|error {
    string getQueryResultsPath = PROJECTS_PATH + SLASH + projectId + QUERIES_PATH + SLASH + jobId;
    if (nextPageToken != "") {
        getQueryResultsPath = getQueryResultsPath + QUESTION_MARK + PAGE_TOKEN_PATH +  nextPageToken;
    }
    var httpResponse = self.bigqueryClient->get(getQueryResultsPath);

    if (httpResponse is http:Response) {
        int statusCode = httpResponse.statusCode;
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (statusCode == http:OK_200) {
                QueryResults queryResults = convertToQueryResults(jsonResponse);
                return queryResults;
            } else {
                return setResponseError(jsonResponse);
            }
        } else {
            error err = error(BIGQUERY_ERROR_CODE,
            { message: "Error occurred while accessing the JSON payload of the response" });
            return err;
        }
    } else {
        error err = error(BIGQUERY_ERROR_CODE, { message: "Error occurred while invoking the REST API" });
        return err;
    }
}

public function Client.init(BigqueryConfiguration bigqueryConfig) {
    http:AuthConfig? authConfig = bigqueryConfig.clientConfig.auth;
    if (authConfig is http:AuthConfig) {
        authConfig.refreshUrl = REFRESH_URL;
        authConfig.scheme = http:OAUTH2;
    }
}

# BigqueryConfiguration is used to set up the Google Bigquery configuration. In order to use
# this Connector, you need to provide the oauth2 credentials.
# + clientConfig - The HTTP client congiguration
public type BigqueryConfiguration record {
    http:ClientEndpointConfig clientConfig = {};
};
