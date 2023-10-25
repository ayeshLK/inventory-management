import ballerina/http;

service / on new http:Listener(9090) {

    resource function get products() returns Product[] {
        return products.toArray();
    }

    resource function get products/[int id]() returns Product? {
        return products[id];
    }

    resource function get products/[int id]/inventory() returns Inventory|http:NotFound {
        Inventory? inventoryDetails = inventory[id];
        if inventoryDetails is () {
            return <http:NotFound>{
                body: "Requested product unavailable"
            };
        }
        return inventoryDetails;
    }

    resource function put products/[int id]/inventory(InventoryUpdate update)
        returns http:Accepted|http:NotAcceptable|http:NotFound {
        Inventory? inventoryDetails = inventory[id];
        if inventoryDetails is Inventory {
            int currentQuantity = inventoryDetails.quantityAvailable;
            if currentQuantity >= update.requestedQuantity {
                inventoryDetails.quantityAvailable = currentQuantity - update.requestedQuantity;
                return http:ACCEPTED;
            }
            return <http:NotAcceptable>{
                body: "Requested quantity unavailable"
            };
        }
        return <http:NotFound>{
            body: "Requested product unavailable"
        };
    }
}

type InventoryUpdate record {|
    int requestedQuantity;
|};
