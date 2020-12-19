
export default class MailEntity
  constructor: () ->

  @from_json: (json) ->
    entity = new MailEntity()
    entity.id = json.id
    entity.name = json.name
    entity
