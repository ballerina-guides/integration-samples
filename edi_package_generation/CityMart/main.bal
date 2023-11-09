import ballerina/http;
import ballerinax/edifact.d03a.supplychain.mORDERS;


service / on new http:Listener(8090) {
   resource function post .(http:Request req) returns string|error|http:Response {
       // get EDI message from the payload
       string ediMsg = check req.getTextPayload();
       //  transformation and data mapping : process EDI message request
       mORDERS:EDI_ORDERS_Purchase_order_message purchaseOrder = check mORDERS:fromEdiString(ediMsg);
       mORDERS:Segment_group_28_GType qtyData = purchaseOrder.Segment_group_28[0];
       mORDERS:Segment_group_2_GType[] parties = purchaseOrder.Segment_group_2;
       mORDERS:DATE_TIME_PERIOD_Type[] dateTimePeriods = purchaseOrder.DATE_TIME_PERIOD;
       string productIdentifier = qtyData.LINE_ITEM?.ITEM_NUMBER_IDENTIFICATION?.Item_identifier ?: "";
       int productQty = check int:fromString(qtyData.QUANTITY[0].QUANTITY_DETAILS.Quantity);
       string? buyerName = "";
       foreach var party in parties {
           mORDERS:NAME_AND_ADDRESS_Type nameAndAddress = party.NAME_AND_ADDRESS;
           if (nameAndAddress.Party_function_code_qualifier == "BY") {
               buyerName = nameAndAddress?.PARTY_IDENTIFICATION_DETAILS?.Party_identifier;
           }
       }
       string? orderDate = "";
       foreach var dateTime in dateTimePeriods {
           if (dateTime.DATE_TIME_PERIOD.Date_or_time_or_period_function_code_qualifier == "137") {
               orderDate = dateTime.DATE_TIME_PERIOD.Date_or_time_or_period_text;
           }
       }
       var supplierRequest = {
           buyerName: buyerName,
           date: orderDate,
           productIdentifier: productIdentifier,
           productQty: productQty
       };
       // responding
       return supplierRequest.toBalString();
   }
}
