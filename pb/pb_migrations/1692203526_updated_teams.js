/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8qpxfloij3mbahc")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "57df9tf6",
    "name": "bought",
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

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8qpxfloij3mbahc")

  // remove
  collection.schema.removeField("57df9tf6")

  return dao.saveCollection(collection)
})
