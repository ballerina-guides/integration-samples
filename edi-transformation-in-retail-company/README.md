# EDI Transformation in retail company

## Scenario

A retail company orders products from a variety of suppliers. To make these transactions smoother and more efficient, they decide to implement EDI, which will standardize the way they exchange business documents like purchase orders and invoices with their suppliers.

## Application Integration Use Case:

The process might look something like this from the suppliers point of view.

* The supplier's system receives an EDI-formatted purchase order, translates it back into a format that their system can understand, and processes the order accordingly.

* Once the order is fulfilled, the supplier creates an invoice, transforms it into an EDI format, and sends it back to the retailer's system using EDI communication.

## EDI transformations

The project contains two separate modules each responsible for order and invoice EDI transformations.

