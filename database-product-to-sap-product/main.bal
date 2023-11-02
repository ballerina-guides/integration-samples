import ballerina/http;
import ballerina/log;
import ballerina/persist;

const SAP_REQUEST_PATH = "/sap/API_PRODUCT_SRV/A_Product";
const SAP_URL = "https://my401785.s4hana.cloud.sap/sap/opu/odata";
const HEADER_KEY_CSRF_TOKEN = "x-csrf-token";
const HEADER_FETCH_VALUE = "fetch";

final map<string> & readonly productIdMap = {"001": "F-10B", "002": "PIP01"};
final map<string> & readonly productTypeMap = {"Finished Product": "FERT", "Metal Tubing": "PIPE"};
final map<string> & readonly productGroupMap = {"Finished Goods": "L004", "Raw Material": "L002"};
final map<string> & readonly baseUnitMap = {"Piece": "PC", "Liter": "L"};
final map<string> & readonly industryMap = {"Manufacturing": "M"};

final http:Client sapHttpClient = check getSAPHttpClient();

configurable SAPAuthConfig sapAuthConfig = ?;

public function main() {
    Product[]|error dbProducts = getProductDataFromDatabase();
    if dbProducts is error {
        log:printError(string `Error while retrieving products from the database: ${dbProducts.message()}`);
        return;
    }
    log:printInfo(string `Successfully retrieved products from the database`);
    SAPProduct[]|error sapProducts = transformProductData(dbProducts);
    if sapProducts is error {
        log:printError(string `Error while transforming products: ${sapProducts.message()}`);
        return;
    }
    error? sapProductError = createSAPProducts(sapProducts);
    if sapProductError is error {
        log:printError(string `Error while creating products: ${sapProductError.message()}`);
    }
}

isolated function getSAPHttpClient() returns http:Client|error {
    http:CredentialsConfig basicAuthHandler = {username: sapAuthConfig.username, password: sapAuthConfig.password};
    return new (url = SAP_URL, auth = basicAuthHandler, cookieConfig = {enabled: true});
}

isolated function getProductDataFromDatabase() returns Product[]|error {
    Client sClient = check new ();
    stream<Product, persist:Error?> products = sClient->/products();
    return from var product in products
        where product is Product
        select product;
}

isolated function transformProductData(Product[] dbProducts) returns SAPProduct[]|error {
    return from Product dbProduct in dbProducts
        select {
            Product: productIdMap.get(dbProduct.id),
            ProductType: productTypeMap.get(dbProduct.'type),
            ProductGroup: productGroupMap.get(dbProduct.group),
            BaseUnit: baseUnitMap.get(dbProduct.baseUnit),
            GrossWeight: dbProduct.grossWeight.toBalString(),
            NetWeight: dbProduct.netWeight.toBalString(),
            WeightUnit: dbProduct.weightUnit,
            IndustrySector: industryMap.get(dbProduct.industry),
            to_Description: {results: []}
        };
}

isolated function createSAPProducts(SAPProduct[] sapProducts) returns error? {
    string csrfToken = check getCsrfToken();
    map<string|string[]> headerParams = {[HEADER_KEY_CSRF_TOKEN] : csrfToken, "Accept": "application/json"};
    foreach SAPProduct sapProduct in sapProducts {
        string productId = sapProduct.Product;
        http:Response|http:ClientError response = sapHttpClient->post(
        path = SAP_REQUEST_PATH,
        message = sapProduct,
        headers = headerParams
        );
        if response is http:ClientError {
            log:printInfo(string `Error while creating product ${productId}: ${response.message()}`);
            continue;
        }
        if response.statusCode != http:STATUS_CREATED {
            log:printInfo(string `Error: ${check response.getTextPayload()}`);
            continue;
        }
        json responseBody = check response.getJsonPayload();
        string sapProductId = check responseBody.d.Product;
        log:printInfo(string `Successfully created an SAP product with id: ${sapProductId}`);
    }
}

isolated function getCsrfToken() returns string|error {
    http:Response|http:ClientError response = sapHttpClient->get(
        path = SAP_REQUEST_PATH,
        headers = {[HEADER_KEY_CSRF_TOKEN] : HEADER_FETCH_VALUE}
        );
    if response is http:ClientError {
        return response;
    }
    if response.statusCode == http:STATUS_OK {
        return (check response.getHeaders(HEADER_KEY_CSRF_TOKEN))[0];

    }
    return error(string `Error: ${check response.getTextPayload()}`);
}
