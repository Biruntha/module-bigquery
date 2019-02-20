import ballerina/config;
import ballerina/io;
import ballerina/test;
import ballerina/time;
import ballerina/internal;

@test:Config
function testListProjects() {
    io:println("-----------------Test case for listProjects method------------------");
    internal:JwtHeader header = {};
    header.alg = "RS256";
    header.typ = "JWT";

    internal:JwtPayload payload = {};
    payload.iss = "service-account-bq-streaming@dataservices-non-prod.iam.gserviceaccount.com";
    payload.aud = ["https://www.googleapis.com/oauth2/v4/token"];

    int iat = (time:currentTime().time/1000) - 60;
    int exp = iat + 3600;
    payload.exp = exp;
    payload.iat = iat;

    map<any> customClaims = {};
    customClaims["scope"] = "https://www.googleapis.com/auth/bigquery";
    payload.customClaims = customClaims;
    payload.sub = "service-account-bq-streaming@dataservices-non-prod.iam.gserviceaccount.com";


    internal:JWTIssuerConfig config = {};
    config.keyAlias = "privatekey";
    config.keyPassword = "notasecret";
    config.keyStoreFilePath = "/home/biruntha/Desktop/Bigquery/BQNonProd.p12";
    config.keyStorePassword = "notasecret";
    string|error response = issue(header, payload, config);
    if(response is string) {
        io:println("JWT token: ", response);
    } else {
        io:println("Error: ", response);
    }
}