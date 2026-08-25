import ballerinax/edifact.d03a.retail.mREQOTE;

function transformQuoteRequest(mREQOTE:EDI_REQOTE_REQOTE quote) returns QuoteRequest|error {
    QuoteRequest quoteRequest = {accountName: "", oppName: ""};

    mREQOTE:Group_1_GType[] references = quote.group_1;
    foreach mREQOTE:Group_1_GType ref in references {
        mREQOTE:REFERENCE_GType? reference = ref.Reference?.REFERENCE;
        if reference is () || reference.Reference_code_qualifier != "AES" {
            continue;
        }
        string? oppId = reference.Reference_identifier;
        if oppId is () {
            return error("Opportunity ID is not given");
        }
        quoteRequest.oppName = oppId;
    }

    mREQOTE:Group_11_GType[] parties = quote.group_11;
    foreach mREQOTE:Group_11_GType party in parties {
        if party.Name_and_address?.PARTY_FUNCTION_CODE_QUALIFIER != "BY" {
            continue;
        }
        string? prospectId = party.Name_and_address?.PARTY_IDENTIFICATION_DETAILS?.Party_identifier;
        if prospectId is () {
            return error("Prospect identifier not available in quote.");
        }
        quoteRequest.accountName = prospectId;
    }

    mREQOTE:Group_27_GType[] items = quote.group_27;
    foreach mREQOTE:Group_27_GType item in items {
        string? itemId = item.Line_item?.LINE_ITEM_IDENTIFIER;
        if itemId is () {
            return error("Item ID is not given");
        }
        ItemData itemData = {itemId};
        foreach mREQOTE:Quantity_Type quantity in item.Quantity {
            mREQOTE:QUANTITY_DETAILS_GType? details = quantity?.QUANTITY_DETAILS;
            if details is () || details.Quantity_type_code_qualifier != "21" {
                continue;
            }
            int|error amount = int:fromString(details.Quantity);
            if amount is error {
                return error("Quantity must be a valid number.");
            }
            itemData.quantity = amount;
            break;
        }
        quoteRequest.itemData.push(itemData);
    }
    return quoteRequest;
}
