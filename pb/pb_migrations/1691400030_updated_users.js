/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8o9rndue7701lca")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "fbhfxxgb",
    "name": "team",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "collectionId": "8qpxfloij3mbahc",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": 1,
      "displayFields": []
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8o9rndue7701lca")

  // remove
  collection.schema.removeField("fbhfxxgb")

  return dao.saveCollection(collection)
})
