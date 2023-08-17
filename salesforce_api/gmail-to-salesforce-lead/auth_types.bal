type GmailOAuth2Config record {|
    string refreshToken;
    string clientId;
    string clientSecret;
|};

type SalesforceOAuth2Config record {|
    string clientId;
    string clientSecret;
    string refreshToken;
    string baseUrl;
    string refreshUrl;
|};


