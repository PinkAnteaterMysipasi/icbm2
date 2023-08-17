/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("j8fw5h801zf0725")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "vpdd748l",
    "name": "attempt_dur",
    "type": "number",
    "required": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("j8fw5h801zf0725")

  // remove
  collection.schema.removeField("vpdd748l")

  return dao.saveCollection(collection)
})
