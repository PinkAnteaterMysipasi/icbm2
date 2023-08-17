/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "lthg3gtwyk9q4wv",
    "created": "2023-08-07 11:04:41.869Z",
    "updated": "2023-08-07 11:04:41.869Z",
    "name": "problems",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "kg7gidqo",
        "name": "name",
        "type": "text",
        "required": true,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("lthg3gtwyk9q4wv");

  return dao.deleteCollection(collection);
})
