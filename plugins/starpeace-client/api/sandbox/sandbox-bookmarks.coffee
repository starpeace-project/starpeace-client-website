import _ from 'lodash'

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default class SandboxInventions
  constructor: (@sandbox) ->


  get_bookmarks: (corporation_id) ->
    return _.cloneDeep(@sandbox.sandbox_data?.bookmarks_by_corporation_id[corporation_id]?.bookmarks || [])

  create_bookmark: (corporation_id, parameters) ->
    throw new Error(400) unless parameters.parentId?.length
    throw new Error(400) unless parameters.name?.length

    @sandbox.sandbox_data.bookmarks_by_corporation_id[corporation_id] = { bookmarks: [] } unless @sandbox.sandbox_data.bookmarks_by_corporation_id[corporation_id]?
    order = _.filter(@sandbox.sandbox_data.bookmarks_by_corporation_id[corporation_id].bookmarks, (bookmark) -> bookmark.parentId == parameters.parentId).length

    if parameters.type == 'FOLDER'
      item = {
        type: 'FOLDER'
        id: Utils.uuid()
        parentId: parameters.parentId
        name: parameters.name
        order: order
      }
    else if parameters.type == 'LOCATION'
      throw new Error(400) unless parameters.mapX?
      throw new Error(400) unless parameters.mapY?
      item = {
        type: 'LOCATION'
        id: Utils.uuid()
        parentId: parameters.parentId
        name: parameters.name
        order: order
        mapX: parameters.mapX
        mapY: parameters.mapY
      }
    else if parameters.type == 'BUILDING'
      throw new Error(400) unless parameters.buildingId?.length
      throw new Error(400) unless parameters.mapX?
      throw new Error(400) unless parameters.mapY?
      item = {
        type: 'BUILDING'
        id: Utils.uuid()
        parentId: parameters.parentId
        name: parameters.name
        order: order
        buildingId: parameters.buildingId
        mapX: parameters.mapX
        mapY: parameters.mapY
      }
    else
      throw new Error(400)

    @sandbox.sandbox_data.bookmarks_by_corporation_id[corporation_id].bookmarks.push item
    return _.cloneDeep(item)

  update_bookmarks: (corporation_id, deltas) ->
    @sandbox.sandbox_data.bookmarks_by_corporation_id[corporation_id] = { bookmarks: [] } unless @sandbox.sandbox_data?.bookmarks_by_corporation_id[corporation_id]?

    updated = []
    for delta in deltas
      existing = _.find(@sandbox.sandbox_data.bookmarks_by_corporation_id[corporation_id].bookmarks, (bookmark) -> bookmark.id == delta.id)
      if existing?
        existing.parentId = delta.parentId if delta.parentId?
        existing.order = delta.order if delta.order?
        updated.push existing
    return _.cloneDeep(updated)
