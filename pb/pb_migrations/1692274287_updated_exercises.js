/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("j8fw5h801zf0725")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "mu6rqfiv",
    "name": "reward",
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
  collection.schema.removeField("mu6rqfiv")

  return dao.saveCollection(collection)
})
