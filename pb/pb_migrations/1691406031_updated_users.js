/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8o9rndue7701lca")

  collection.name = "players"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("8o9rndue7701lca")

  collection.name = "users"

  return dao.saveCollection(collection)
})
