
export default class Utils

  @s4: () -> Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
  @uuid: () -> "#{Utils.s4()}#{Utils.s4()}-#{Utils.s4()}-#{Utils.s4()}-#{Utils.s4()}-#{Utils.s4()}#{Utils.s4()}#{Utils.s4()}"
