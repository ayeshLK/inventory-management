type Product record {|
    readonly int id;
    string name;
    string description;
    decimal price;
|};

type Inventory record {|
    readonly int productId;
    int quantityAvailable;
|};

table<Product> key(id) products = table [
    {id: 1, name: "Apple MacBook Pro", description: "High-performance laptop with Retina display", price: 1299.99},
    {id: 2, name: "Samsung Galaxy S21", description: "Latest smartphone with 5G support and high-resolution camera", price: 799.99},
    {id: 3, name: "Sony PlayStation 5", description: "Next-gen gaming console with 4K graphics support", price: 499.99},
    {id: 4, name: "DJI Mavic Air 2", description: "High-quality drone with 4K camera and intelligent flight modes", price: 799.99},
    {id: 5, name: "Bose QuietComfort 35 II", description: "Noise-canceling wireless headphones with excellent sound quality", price: 349.99}
];

table<Inventory> key(productId) inventory = table [
    {productId: 1, quantityAvailable: 30},
    {productId: 2, quantityAvailable: 50},
    {productId: 3, quantityAvailable: 20},
    {productId: 4, quantityAvailable: 10},
    {productId: 5, quantityAvailable: 25}
];
