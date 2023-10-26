import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

service OrderService on new http:Listener(9091) {
    private final mysql:Client orderDb;

    public function init() returns error? {
        self.orderDb = check new(host = "localhost", port = 3306, 
            user = "user", password = "password", database = "order_database");
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