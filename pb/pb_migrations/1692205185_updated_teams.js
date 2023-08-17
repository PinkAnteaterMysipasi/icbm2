/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8qpxfloij3mbahc")

  // remove
  collection.schema.removeField("awwlsuof")

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8qpxfloij3mbahc")

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
})
