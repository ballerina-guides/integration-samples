type Header_Type record {|
    string code?;
    string orderId?;
    string organization?;
    string date?;
|};

type Items_Type record {|
    string code?;
    string item?;
    int quantity?;
|};

type SimpleOrder record {|
    Header_Type header;
    Items_Type[] items?;
|};
