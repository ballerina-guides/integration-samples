# Event Driven Order Management System

## Service and Event Composition
Upon user clicking submit button, the HTTP POST endpoint will be called in the Order Service. It will start the event chaining by pushing event to topics. This implementation follows Database per service pattern. Implementation is focused on service compositon and event chaining rather than the business logic for simplicity. 

### Event - HTTP POST /order
#### Service - Order Service
- Validate the data
- Persist Order
- Invoke orderCreatedEvent

### Topic - orderCreatedEvent
#### Service - Payment Service
- Talk to payment gateway and process payment
- Invoke paymentCompletedEvent

### Topic - paymentCompletedEvent
#### Service - Inventory Service
- Update inventory
- Invoke inventoryUpdatedEvent

### Topic - inventoryUpdatedEvent
#### Service - SMS Service
- Send SMS to customer

### Topic - inventoryUpdatedEvent
#### Service - Email Service
- Send Email to customer

### Topic - inventoryUpdatedEvent
#### Service - Order Service
- Update the Order status in db


## Running the Sample

- Start the Kafka Broker - `docker compose up -d`
- Publish types package to local central - `(cd order_types && bal pack && bal push --repository=local)`
- Start Order Service - `(cd order_service && bal run)`
- Start Inventory Service - `(cd inventory_service && bal run)`
- Start Payment Service - `(cd payment_service && bal run)`
- Start Email Service - `(cd email_service && bal run)`
- Start SMS Service - `(cd sms_service && bal run)`


## Testing the Sample

### Create an order
```
curl --location 'http://localhost:9090/order' \
--header 'Content-Type: application/json' \
--data-raw '{
    "customer": {
        "name": "Anjana",
        "email": "test@gmail.com",
        "phoneNumber": "762222222"
    },
    "items": [
        {
            "id": "Item1",
            "quantity": 2
        }
    ],
    "paymentDetails": {
        "name": "NGAS Subashana",
        "cardNumber": "1234",
        "expiryDate": "02/22",
        "cvv": "123"
    }
}'
```

### Check the order status
```
curl --location 'http://localhost:9090/order'
```