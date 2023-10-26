CREATE TABLE order_database.orders (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT,
    `quantity` INT,
    `status` VARCHAR(20) DEFAULT NULL,
    `details` VARCHAR(256) DEFAULT NULL
);

INSERT INTO order_database.orders (`product_id`, `quantity`, `status`, `details`) VALUES
    (1, 5, 'ACCEPTED', 'Order for MacBook Pro'),
    (2, 3, 'DONE', 'Urgent order for Galaxy S21'),
    (3, 2, 'ACCEPTED', 'Order for PlayStation 5 and accessories'),
    (4, 7, 'DONE', 'Completed order for DJI Mavic Air 2');
