import ballerina/http;
import ballerina/sql;

type OrderService service object {
    *http:Service;

    resource function get orders() returns Order[]|error;
    resource function get orders/[int id]() returns Order|OrderNotFound|error;
    resource function post orders(NewOrder newOrder) returns OrderCreated|OrderRejected|error;
};

enum OrderStatus {
    ACCEPTED, REJECTED, DONE
}

type Order record {|
    int id;
    int productId;
    int quantity;
    OrderStatus status;
    string details?;
|};

public type NewOrder record {|
    int productId;
    int quantity;
|};

type OrderCreated record {|
    *http:Created;
    map<string> headers;
|};

type OrderRejected record {|
    *http:BadRequest;
    ErrorDetails body;
|};

type OrderNotFound record {|
    *http:NotFound;
    ErrorDetails body;
|};

type ErrorDetails record {|
    string message;
    string details;
|};
