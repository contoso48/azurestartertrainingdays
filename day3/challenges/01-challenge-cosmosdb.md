# Challenge 01: Cosmos DB

⏲️ *Est. time to complete: 60 min.* ⏲️

## Here is what you will learn 🎯

In this challenge you will learn how to:

- Create a Cosmos DB account
- Add data and query via the data explorer
- Learn about partitions and the effect of cross-partition queries
- Use the Cosmos DB change feed
- Monitor your database

## Table Of Contents

1. [Create a Comsos DB Account, Database and Containers](#create-a-comsos-db-account-database-and-containers)
2. [Add and query data](#add-and-query-data)
3. [Use the Cosmos DB Change Feed](#use-the-cosmos-db-change-feed)
4. [Monitor Cosmos DB](#monitor-cosmos-db)
5. [Azure Samples](#azure-samples)
6. [Cleanup](#cleanup)

## Create a Comsos DB Account, Database and Containers

Before we start creating a database account in Azure, let's have a brief look at the resource model of Cosmos DB. It is made of the following objects:

- _Account_: manages one or more databases
- _Database_: manages users, permissions and containers
- _Container_: a schema-agnostic container of user-generated JSON items and JavaScript based stored procedures, triggers and user-defined-functions (UDFs)
- _Item_: user-generated document stored in a container

![Cosmos DB Resource Model](./images/cosmosdb/resourcemodel.png "Comsos DB Resource Model")

To create a Cosmos DB account, database and the corresponding containers we will use in this challenge, you have two options:

- [Azure Portal](#option-1-azure-portal)
- [Azure Bicep](#option-2-azure-bicep)

Both are decribed in the next chapters, choose only one of them.

:::tip
📝 The "Bicep" option is much faster, because it will create all the objects automatically at once. If you want to go with that one, please also have a look at the "Create View" in the portal to make yourself familiar with all the settings you can adjust for a Cosmos DB account, db and container.
:::

### Option 1: Azure Portal

#### Create a Comsos DB Account

In the Azure Portal, click on _Create Resource_ and select _Azure Cosmos DB_. When prompted to select an API option, please choose _Core (SQL) - Recommended_.

![Cosmos DB API](./images/cosmosdb/portal_create_api_option.png "Cosmos DB API options")

:::tip
📝 As you might already know, Comsos DB supports a variety of APIs that you can use, depending on your use case. You can e.g. use the _MongoDB_ API - as the _Cosmos DB Core API_ - for storing documents, take the _Cassandra_ API, if you have to deal with timeseries oriented data or _Gremlin_, if you want to store the data in a graph with _vertices_ and _edges_. You can find out more about all the options (and when to choose which API) in the official documentation: <https://docs.microsoft.com/en-us/azure/cosmos-db/choose-api>.
:::

On the wizard, please choose/enter the following parameters:

| Option Name      | Value                                                                                                         |
| ---------------- | ------------------------------------------------------------------------------------------------------------- |
| _Resource Group_ | Create a new resource group called **rg-cosmos-challenge**                                                    |
| _Account Name_   | Enter a globally unique account name, like **azdc-cosmos-challenge**                                          |
| _Location_       | West Europe                                                                                                   |
| _Capacity mode_  | **Serverless** (we use the serverless option, because it's the cheapest option for development/test purposes) |

![Cosmos DB Create Wizard](./images/cosmosdb/portal_create_overview.png "Cosmos DB Create Wizard")

Leave all other options as suggested by the wizard and finally click _Create_. After approximately 4-8 minutes, the database account has been created. Please go to the resource as we now need to add the database and containers for our data.

#### Create a Database and Containers

The most convenient way to add a database and containers to a CosmosDB account is the _Data Explorer_. You can find the option in the context menu of the Comsos DB account overview in the Azure Portal. We now need to create two container, so please go to the _Data Explorer_ and click on _New Container_ in the toolbar.

![Create a new container in the data explorer](./images/cosmosdb/portal_create_container.png "Create Container")

#### Container: Customer

| Option Name     | Value                                                                                                               |
| --------------- | ------------------------------------------------------------------------------------------------------------------- |
| _Database id_   | Select the option _Create new_ and enter the name _AzDCdb_. With this first container, we also create the database. |
| _Container id_  | customer                                                                                                            |
| _Partition key_ | /customerId                                                                                                         |

Click _Ok_ and when the operation has finished, go to the _Settings_ view of the _customer_ container in the _Data Explorer_ and adjust the _Indexing Policy_. Copy the following JSON document in the editor and click _Save_ in the toolbar:

```json
{
    "indexingMode": "consistent",
    "automatic": true,
    "includedPaths": [
        {
            "path": "/*"
        }
    ],
    "excludedPaths": [
        {
            "path": "/title/?"
        },
        {
            "path": "/firstName/?"
        },
        {
            "path": "/lastName/?"
        },
        {
            "path": "/emailAddress/?"
        },
        {
            "path": "/phoneNumber/?"
        },
        {
            "path": "/creationDate/?"
        },
        {
            "path": "/addresses/*"
        },
        {
            "path": "/\"_etag\"/?"
        }
    ]
}
```

:::tip
📝 Why are we adjusting the indexing policy? We'll come back to that point later. Just be a little bit patient.
:::

#### Container: Product

| Option Name     | Value                                                 |
| --------------- | ----------------------------------------------------- |
| _Database id_   | Select the option _Use existing_ and select _AzDCdb_. |
| _Container id_  | customer                                              |
| _Partition key_ | /customerId                                           |

After you have created the database and the containers, the _Data Explorer_ should look like that:

![Create a new container in the data explorer](./images/cosmosdb/portal_create_container_explorer.png "Create Container")

Now we are ready to add data. You can move on to [Add and query data](#add-and-query-data)

### Option 2: Azure Bicep

You can run the following commands on your local machine or in the Azure Cloud Shell. If Azure Bicep isn't installed already, simply add it via the Azure CLI:

```shell
$ az bicep install #only needed, if bicep isn't present in the environment

$ cd day3/challenges/cosmosdb

$ az group create --name rg-cosmos-challenge --location westeurope
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cosmos-challenge",
  "location": "westeurope",
  "managedBy": null,
  "name": "rg-cosmos-challenge",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}

$ az deployment group create -f cosmos.bicep -g rg-cosmos-challenge
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-cosmos-challenge/providers/Microsoft.Resources/deployments/cosmos",
  "location": null,
  "name": "cosmos",
  ...
  ...
  ...
  ...
}
```

After approximately 8-10 minutes, the Cosmos DB account, database and the containers (_product_ and _customer_) have been created and are ready to be used. Open the account in the Azure Portal and navigate to the _Data Explorer_. It should look like similar to that:

![Create a new container in the data explorer](./images/cosmosdb/portal_create_container_explorer.png "Create Container")

Let's add data to the two containers.

## Add and query data

Now, it's time to add data to the _customer_ and _product_ containers. There a two datasets that have been prepared for you.

### Customer Dataset

The _customer_ dataset contains of two types of objects that we put in the same container: **customer** and **salesOrder**. Wait...two object types in the same container? You learned that when dealing with data in a (relational) database, the data should always be normalized and that it's best to have one object type in one table! "This is totally against that principle", you might think.

Yes, you are right - in a relational environment. But here, we are working with a NoSQL database and things are a little bit different. Mixing object types in one container is totally fine (and even a best practice in terms of performance). In this non-relational world, you also tend to follow the "de-normalization" principle. That means that data duplication, embedding etc. is not only possible, but encouraged. You optimize data models to make sure that all the required data is ready to be served by queries.

You can download the customer dataset here: <https://azuredevcollegesa.blob.core.windows.net/cosmosdata/customer.json>

#### Customer Data

A customer document has a property ```type``` set to _customer_ and contains several properties like ```firstName```, ```lastName```, ```emailAddress``` etc. You can see, that it also uses document embedding for ```addresses``` - the property is an array, so you can add multiple addresses to one customer.

:::tip When to use embedding? When to use referencing?
📝 To model relations in a document-oriented database, you have two choices: embedding and referencing. But which should you choose when?

| Embedding                                     | Referencing                                        |
| --------------------------------------------- | -------------------------------------------------- |
| 1:1 relationship                              | 1:many relationship (especially if unbounded)      |
| 1:few relationship                            | Many:many relationship                             |
| Related items are queried or updated together | Related items are queried or updated independently |
:::

The partition key of the container has been set to ```/customerId```, so each customer is placed in its own logical partition. With that approach, we achive the best distribution of data in terms of horizontal scaling and will never hit any storage limits - so we are prepared for massive growth of the data/application. On the other hand, this is not the best way when we want to search within our customer base, because we will definitely have cross-partition queries and they will consume more and more RUs as the data grows. How to deal with such a situation is discussed later in the challenge.

Here's a sample object from the container:

```json
{
    "id": "0012D555-C7DE-4C4B-B4A4-2E8A6B8E1161",
    "type": "customer",
    "customerId": "0012D555-C7DE-4C4B-B4A4-2E8A6B8E1161",
    "title": "",
    "firstName": "Franklin",
    "lastName": "Ye",
    "emailAddress": "franklin9@adventure-works.com",
    "phoneNumber": "1 (11) 500 555-0139",
    "creationDate": "2014-02-05T00:00:00",
    "addresses": [
      {
        "addressLine1": "1796 Westbury Dr.",
        "addressLine2": "",
        "city": "Melton",
        "state": "VIC",
        "country": "AU",
        "zipCode": "3337"
      }
    ],
    "password": {
      "hash": "GQF7qjEgMl3LUppoPfDDnPtHp1tXmhQBw0GboOjB8bk=",
      "salt": "12C0F5A5"
    },
    "salesOrderCount": 2
}
```

#### SalesOrder Data

The salesorder object is similar to the customer object (```type``` is set to _salesOrder_). It has properties that you would expect for a sales order like ```orderDate```, ```shipDate```, ```customerId``` etc. Also, embedding is used to save the line items of the order.

As these objects are stored in the same collection as the customers (```customer``` collection), the partition key is also set to ```customerId```. This has a huge advantage over storing the sales orders in a separate collection: you can query both customer and the corresponding sales orders in one query - and all items queried lie in the same logical thus physical partition. Queries are super fast and - from a relational standpoint - you avoid costly JOINs over several tables or multiple queries at all.

Here's a sample object from the container:

```json
{
    "id": "091F884C-DC00-4422-9B89-3438B22DEF07",
    "type": "salesOrder",
    "customerId": "0012D555-C7DE-4C4B-B4A4-2E8A6B8E1161",
    "orderDate": "2014-03-03T00:00:00",
    "shipDate": "2014-03-10T00:00:00",
    "details": [
      {
        "sku": "TT-M928",
        "name": "Mountain Tire Tube",
        "price": 4.99,
        "quantity": 1
      },
      {
        "sku": "PK-7098",
        "name": "Patch Kit/8 Patches",
        "price": 2.29,
        "quantity": 1
      },
      {
        "sku": "TI-M267",
        "name": "LL Mountain Tire",
        "price": 24.99,
        "quantity": 1
      }
    ]
}
```

### Product Dataset

The product dataset contains just one object type: ```product```. It simply stores the information for each product like ```name```, ```price```, ```categoryName```. The collection is partitioned by ```/categoryId```, so products are logically grouped by and can be queried via category.

You can download the product dataset here: <https://azuredevcollegesa.blob.core.windows.net/cosmosdata/product.json>

#### Product Data

Here's a sample object from the container:

```json
{
    "id": "9190229B-1372-4997-8F64-5B3E7A2459C5",
    "categoryId": "86F3CBAB-97A7-4D01-BABB-ADEFFFAED6B4",
    "categoryName": "Accessories, Tires and Tubes",
    "sku": "TT-M928",
    "name": "Mountain Tire Tube",
    "description": "The product called \"Mountain Tire Tube\"",
    "price": 4.99,
    "tags": [
      {
        "id": "66D8EA21-E1F0-471C-A17F-02F3B149D6E6",
        "name": "Tag-83"
      },
      {
        "id": "6FB11EB9-319C-431C-89D7-70113401D186",
        "name": "Tag-154"
      },
      {
        "id": "8AAFD985-8BCE-4FA8-85A2-2CA67D9DF8E6",
        "name": "Tag-172"
      },
      {
        "id": "A4D9E596-B630-4792-BDD1-7D6459827820",
        "name": "Tag-164"
      }
    ]
}
```

### Upload the datasets

To add the datasets to Cosmos DB, go to the _Data Explorer_ and first open the _Items_ menu item of the _customer_ container. When the tab appears, you'll see an _Upload Item_ button in the toolbar. Click on that button, then select the _customer.json_ file that you previously downloaded and click _Upload_.

![Upload data to a container in the data explorer](./images/cosmosdb/portal_dataexplorer_upload.png "Upload data")

:::tip
📝 Depending on your network speed and latency, this should take about 2-3 minutes.
:::

Do the same with the _product.json_ file for the _product_ collection.

### Queries

Let's work with the data and execute some queries against the two containers.

:::tip
📝 You can open the Data Explorer as a separate window via the toolbar.
:::

#### Simple Query

First, let's issue queries in the _customer_ container where we have customer and sales order objects. Let's start with a few simple queries.

Therefor, go to the Data Explorer, open the _Items_ menu item of the _customer_ container and click on _New SQL Query_ in the toolbar.

![Create new SQL query in Data Explorer](./images/cosmosdb/portal_dataexplorer_newquery.png "New SQL Query")

In the newly created tab, enter the following SQL command and click _Execute_.

```sql
SELECT * from c
```

As you can see in the _Results_ tab, Cosmos DB returns a set of documents, that live in the _customer_ container. It returns a paged resultset, showing documents in batches of 100 items.

![Results of a SQL query in Data Explorer](./images/cosmosdb/portal_dataexplorer_results.png "SQL Query resultset")

Also, have a look at the _Query Stats_ tab. Here you can see

There is a bunch of properties, that have a special meaning for documents stored via the SQL API, e.g. _id_, __rid_, __ts_ etc. All properties are described in the following table (excerpt from the official Comsos DB documentation):

| Property       | Description                                                                                                                                                                                                                                                                               |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| _id_           | Required. It is a user settable property. It is the unique attribute that identifies the document, that is, no two documents share the same ID **within a logical partition**. Partition and ID uniquely identifies an item in the database. The id field must not exceed 255 characters. |
| __rid_         | It is a system generated property. The resource ID (_rid) is a unique identifier that is also hierarchical per the resource stack on the resource model. It is used internally for placement and navigation of the document resource.                                                     |
| __ts_          | It is a system generated property. It specifies the last updated timestamp of the resource. The value is a timestamp.                                                                                                                                                                     |
| __self_        | It is a system generated property. It is the unique addressable URI for the resource.                                                                                                                                                                                                     |
| __etag_        | It is a system generated property that specifies the resource etag required for [optimistic concurrency control](https://docs.microsoft.com/en-us/azure/cosmos-db/database-transactions-optimistic-concurrency#optimistic-concurrency-control).                                           |
| __attachments_ | It is a system generated property that specifies the addressable path for the attachments resource.                                                                                                                                                                                       |

Let's execute another query to determine the amount of documents stored in the _customer collection.

```sql
SELECT COUNT(1) as numDocuments FROM c
```

The result should produce a JSON document like this:

```json
[
  {
    "numDocuments": 50584
    }
]
```

You can also query the value directly by adding the ```VALUE``` keyword:

```sql
SELECT VALUE(COUNT(1)) FROM c
```

Result:

```json
[
  50584
]
```

#### Indexing and Partition-Aware Queries

In Azure Cosmos DB, documents are automatically indexed without having to define a schema or create any secondary indexes. Every document that is stored in Cosmos DB is converted to a tree object, so that you can reference each property via its path.

![Tree respresentation in Cosmos DB](./images/cosmosdb/document_tree.png "Propery tree")

E.g., you can access the _city_ property of the first address of a customer object via ```/addresses/0/city```.

Adding an index can significantly reduce the query time and consumed RUs, but can also be expensive when adding or updating a document, because after each action, the index has to be recalculated/recreated for the document data. So, if you have write-intensive workloads, it better to tweak the indexing policy.

Let's have a look at the _customer_ document. The indexing policy has been adjusted to NOT(!) index fields like _firstName_, _title_, _addresses_ etc. Adding or updating a customer consumes ~ 8.5 RUs. Using the standard indexing policy (which means all properties will be indexed), the same operation consumes ~13.2 RUs. That's about 150% "the price".

:::tip Index Types
📝 Cosmos DB supports several index types like range, spatial (for geo-data) and composite indexes. To learn more about when to use what kind of index, refer to the official documentation: <https://docs.microsoft.com/en-us/azure/cosmos-db/index-overview>.
:::

Select cross-partition:

SELECT * FROM c where c.firstName = "Franklin"

Select with partition:

SELECT * FROM c where c.firstName = "Franklin" and c.customerId = "0012D555-C7DE-4C4B-B4A4-2E8A6B8E1161"

Adjust index (when you know how to search):

SELECT * FROM c where c.firstName = "Franklin"

With index and partition

SELECT * FROM c where c.firstName = "Franklin" and c.customerId = "0012D555-C7DE-4C4B-B4A4-2E8A6B8E1161"

#### Can I do (relational) JOINs?

Inter-document joins are supported, see . Multiple types in same partition key / collection...

#### Aggerations

E.g. average price per category

SELECT c.categoryName as Category, AVG(c.price) as avgPrice FROM c group by c.categoryName

Partition-aware:

SELECT c.categoryName as Category, AVG(c.price) as avgPrice FROM c where c.categoryId = "75BF1ACB-168D-469C-9AA3-1FD26BB4EA4C" group by c.categoryName

TOP 10 Customers by Sales Order Count

SELECT TOP 10 c.firstName, c.lastName, c.salesOrderCount FROM c WHERE c.type = 'customer' ORDER BY c.salesOrderCount DESC

## Use the Cosmos DB Change Feed

Which APIs are supported...

### Why to use it?

![Overview Change Feed](./images/cosmosdb/changefeedvisual.png)

### What does it support?

### How to consume the Change Feed?

Describe Azure Function and ChangeFeed Processor

### Sample: Create a CustomerView collection for query optimized access to Customer data

```shell
az group create -n day3cosmos -l westeurope
az deployment group create -g day3cosmos --template-file cosmos.bicep
```

Create collection "customerView" (partition key '/area' - see bicep file) + Az Function under day3/challenges/cosmosdb/func (Adjust connection string to db)

Explain what is done in index.js

Run function (let it process all changes --> then show collection content)

Update a customer in original collection and show result in "view" collection --> they are in sync

## Monitor Cosmos DB

## Azure Samples / Further Information

- <https://aka.ms/PracticalCosmosDB>  - model a blog platform
- <https://youtube.com/azurecosmosdb> - videos on CosmosDB
- <https://devblogs.microsoft.com/cosmosdb/> - official CosmosDB blog

## Cleanup

No clean-up needed this time. We will reuse the Cosmos DB account in the Azure Cognitive Search challenge. So please, don't delete any of the resources yet.

[◀ Previous challenge](./00-challenge-baseline.md) | [🔼 Day 3](../README.md) | [Next challenge ▶](./02-challenge-sql.md)