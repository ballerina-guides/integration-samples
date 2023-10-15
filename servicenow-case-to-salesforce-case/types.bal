import ballerina/time;
type CaseData record {
    string number;
    string sys_created_on;
    string priority;
    string case;
    record {string name;} account;
};

type SalesforceCase record {|
    string Name;
    string Account__c;
    string Created_on__c;
    string Priority__c;
    string Summary__c;
|};

type Id record {|
    string Id;
|};

type DateRange record {|
    string 'start;
    string end;
    time:Civil now;
|};
