import ballerina/io;
import ballerina/encoding;
import ballerina/internal;

# Issue a JWT token.
#
# + header - JwtHeader object
# + payload - JwtPayload object
# + config - JWTIssuerConfig object
# + return - JWT token string or an error if token validation fails
public function issue(internal:JwtHeader header, internal:JwtPayload payload, internal:JWTIssuerConfig config) returns (string|error) {
    io:println("Inside issue method--------------");
    string jwtHeader = check createHeader(header);
    string jwtPayload = check createPayload(payload);
    string jwtAssertion = jwtHeader + "." + jwtPayload;
    KeyStore keyStore = {
        keyAlias : config.keyAlias,
        keyPassword : config.keyPassword,
        keyStoreFilePath : config.keyStoreFilePath,
        keyStorePassword : config.keyStorePassword
    };
    string signature = internal:sign(jwtAssertion, header.alg, keyStore);
    return (jwtAssertion + "." + signature);
}

function createHeader(internal:JwtHeader header) returns (string|error) {
    json headerJson = {};
    if (!validateMandatoryJwtHeaderFields(header)) {
        error jwtError = error(INTERNAL_ERROR_CODE, { message : "Mandatory field signing algorithm(alg) is empty." });
        return jwtError;
    }
    headerJson[ALG] = header.alg;
    headerJson[TYP] = "JWT";
    var customClaims = header["customClaims"];
    if (customClaims is map<any>) {
        headerJson = addMapToJson(headerJson, customClaims);
    }
    string headerValInString = headerJson.toString();
    string encodedPayload = encoding:encodeBase64(headerValInString.toByteArray("UTF-8"));
    return encodedPayload;
}

function createPayload(internal:JwtPayload payload) returns (string|error) {
    json payloadJson = {};
    if (!validateMandatoryFields(payload)) {
        error jwtError = error(INTERNAL_ERROR_CODE,
        { message : "Mandatory fields(Issuer, Subject, Expiration time or Audience) are empty." });
        return jwtError;
    }
    payloadJson[SUB] = payload.sub;
    payloadJson[ISS] = payload.iss;
    payloadJson[EXP] = payload.exp;
    var iat = payload["iat"];
    if (iat is int) {
        payloadJson[IAT] = iat;
    }
    var jti = payload["jti"];
    if (jti is string) {
        payloadJson[JTI] = jti;
    }
    payloadJson[AUD] = convertStringArrayToJson(payload.aud);
    var customClaims = payload["customClaims"];
    if (customClaims is map<any>) {
        payloadJson = addMapToJson(payloadJson, customClaims);
    }
    string payloadInString = payloadJson.toString();
    return encoding:encodeBase64(payloadInString.toByteArray("UTF-8"));
}