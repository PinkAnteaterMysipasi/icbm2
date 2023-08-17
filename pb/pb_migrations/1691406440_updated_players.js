/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8o9rndue7701lca")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "ju88qsab",
    "name": "token",
    "type": "text",
    "required": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8o9rndue7701lca")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "ju88qsab",
    "name": "cookie",
    "type": "text",
    "required": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
})
