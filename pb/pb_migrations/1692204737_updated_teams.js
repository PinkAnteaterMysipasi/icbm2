/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8qpxfloij3mbahc")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "nykonl3c",
    "name": "solved",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "collectionId": "j8fw5h801zf0725",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": null,
      "displayFields": []
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "awwlsuof",
    "name": "attempts",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8qpxfloij3mbahc")

  // remove
  collection.schema.removeField("nykonl3c")

  // remove
  collection.schema.removeField("awwlsuof")

  return dao.saveCollection(collection)
})
