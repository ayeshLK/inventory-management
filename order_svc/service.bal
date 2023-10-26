import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

service OrderService on new http:Listener(9091) {
    private final mysql:Client orderDb;
    private final http:Client inventoryClient;

    public function init() returns error? {
        self.orderDb = check new(host = "localhost", port = 3306, 
            user = "user", password = "password", database = "order_database");
        self.inventoryClient = check new("localhost:9090");
    }

    resource function get orders() returns Order[]|error {
        stream<Order, sql:Error?> ordersStream = self.orderDb->query(`SELECT * FROM orders`);
        return from Order 'order in ordersStream
            select 'order;
    }

    resource function get orders/[int id]() returns Order|OrderNotFound|error {
        Order|error result = self.orderDb->queryRow(`SELECT * FROM orders WHERE ID = ${id}`);
        if result is sql:NoRowsError {
            OrderNotFound orderNotFound = {
                body: {
                    message: string `Order id: ${id} not found`, 
                    details: string `/orders/${id}`
                }
            };
            return orderNotFound;
        }
        return result;
    }

    resource function post orders(NewOrder newOrder) returns OrderCreated|OrderRejected|error {
        InventoryUpdate updateRequest = {
            requestedQuantity: newOrder.quantity
        };
        http:Response inventoryUpdateResponse = check self.inventoryClient->/products/[newOrder.productId]/inventory.put(
            message = updateRequest
        );
        if inventoryUpdateResponse.statusCode == http:STATUS_NOT_FOUND {
            OrderRejected productNotFound = {
                body: {
                    message: string `Product id: ${newOrder.productId} not found`, 
                    details: string `/orders`
                }
            };
            return productNotFound;
        }
        if inventoryUpdateResponse.statusCode == http:STATUS_NOT_ACCEPTABLE {
            OrderRejected quantityUnavailable = {
                body: {
                    message: string `Requested quantity for Product id: ${newOrder.productId} unavailable`, 
                    details: string `/orders`
                }
            };
            return quantityUnavailable;
        }
        if inventoryUpdateResponse.statusCode != http:STATUS_ACCEPTED {
            OrderRejected nonAcceptedResult = {
                body: {
                    message: string `Unknown error occurred while updating inventory`, 
                    details: string `/orders`
                }
            };
            return nonAcceptedResult;
        }
        sql:ExecutionResult result = check self.orderDb->execute(`
            INSERT INTO orders(product_id, quantity, status)
            VALUES (${newOrder.productId}, ${newOrder.quantity}, ${ACCEPTED});`);
        int orderId = check result.lastInsertId.ensureType();
        OrderCreated orderCreated = {
            headers: {
                "Location": string `/orders/${orderId}`
            }
        };
        return orderCreated;
    }
}

type InventoryUpdate record {|
    int requestedQuantity;
|};
