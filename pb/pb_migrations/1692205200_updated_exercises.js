/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("j8fw5h801zf0725")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "jxavp3ql",
    "name": "attempts",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("j8fw5h801zf0725")

  // remove
  collection.schema.removeField("jxavp3ql")

  return dao.saveCollection(collection)
})
