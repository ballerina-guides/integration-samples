import ballerina/websocket;
import ballerina/test;

const WS_INIT = "connection_init";
const WS_ACK = "connection_ack";
const WS_PING = "ping";
const WS_PONG = "pong";
const WS_SUBSCRIBE = "subscribe";
const WS_NEXT = "next";
const WS_COMPLETE = "complete";
const GRAPHQL_TRANSPORT_WS = "graphql-transport-ws";

isolated function initiateGraphqlWsConnection(websocket:Client wsClient) returns websocket:Error? {
    check sendConnectionInitMessage(wsClient);
    check validateConnectionAckMessage(wsClient);
}

isolated function sendConnectionInitMessage(websocket:Client wsClient) returns websocket:Error? {
    check wsClient->writeMessage({'type: WS_INIT});
}

isolated function readNextMessagePayload(websocket:Client wsClient) returns error|json {
    json response = check readMessageExcludingPingMessages(wsClient);
    test:assertEquals(response.'type, WS_NEXT);
    return response.payload;
}

isolated function sendSubscriptionMessage(websocket:Client wsClient, string document, string id = "1") returns websocket:Error? {
    json payload = {'type: WS_SUBSCRIBE, id, payload: {query: document}};
    return wsClient->writeMessage(payload);
}

isolated function validateConnectionAckMessage(websocket:Client wsClient) returns websocket:Error? {
    json response = check wsClient->readMessage();
    test:assertEquals(response.'type, WS_ACK);
}

isolated function readMessageExcludingPingMessages(websocket:Client wsClient) returns json|websocket:Error {
    json message = null;
    while true {
        message = check wsClient->readMessage();
        if message == null {
            continue;
        }
        if message.'type == WS_PING {
            check sendPongMessage(wsClient);
            continue;
        }
        return message;
    }
}

isolated function sendPongMessage(websocket:Client wsClient) returns websocket:Error? {
    json message = {'type: WS_PONG};
    check wsClient->writeMessage(message);
}

isolated function sendComplateMessage(websocket:Client wsClient, string id = "1") returns websocket:Error? {
    check wsClient->writeMessage({'type: WS_COMPLETE, id});
}
