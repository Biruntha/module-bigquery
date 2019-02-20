import ballerina/internal;

function addMapToJson(json inJson, map<any> mapToConvert) returns (json) {
    if (mapToConvert.length() != 0) {
        foreach var key in mapToConvert.keys() {
            var customClaims = mapToConvert[key];
            if (customClaims is string[]) {
                inJson[key] = convertStringArrayToJson(customClaims);
            } else if (customClaims is int[]) {
                inJson[key] = convertIntArrayToJson(customClaims);
            } else if (customClaims is string) {
                inJson[key] = customClaims;
            } else if (customClaims is int) {
                inJson[key] = customClaims;
            } else if (customClaims is boolean) {
                inJson[key] = customClaims;
            }
        }
    }
    return inJson;
}

function convertStringArrayToJson(string[] arrayToConvert) returns (json) {
    json jsonPayload = [];
    int i = 0;
    while (i < arrayToConvert.length()) {
        jsonPayload[i] = arrayToConvert[i];
        i = i + 1;
    }
    return jsonPayload;
}

function convertIntArrayToJson(int[] arrayToConvert) returns (json) {
    json jsonPayload = [];
    int i = 0;
    while (i < arrayToConvert.length()) {
        jsonPayload[i] = arrayToConvert[i];
        i = i + 1;
    }
    return jsonPayload;
}

function validateMandatoryFields(internal:JwtPayload jwtPayload) returns (boolean) {
    if (jwtPayload.iss == "" || jwtPayload.sub == "" || jwtPayload.exp == 0 || jwtPayload.aud.length() == 0) {
        return false;
    }
    return true;
}

function validateMandatoryJwtHeaderFields(internal:JwtHeader jwtHeader) returns (boolean) {
    if (jwtHeader.alg == "") {
        return false;
    }
    return true;
}