
export default class Level
  @LEVELS:
    NONE:
      category: 'NONE'
      text_key: 'level.none.label'
    APPRENTICE:
      CATEGORY: 'APPRENTICE'
      text_key: 'level.apprentice.label'
    ENTREPRENEUR:
      CATEGORY: 'ENTREPRENEUR'
      text_key: 'level.entrepreneur.label'
    TYCOON:
      CATEGORY: 'TYCOON'
      text_key: 'level.tycoon.label'
    MASTER:
      CATEGORY: 'MASTER'
      text_key: 'level.master.label'
    PARADIGM:
      CATEGORY: 'PARADIGM'
      text_key: 'level.paradigm.label'
    LEGEND:
      CATEGORY: 'LEGEND'
      text_key: 'level.legend.label'

  @from_string: (value) ->
    Level.LEVELS[(value || '').toUpperCase()] || Level.LEVELS.NONE
