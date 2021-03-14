module MemberHelper

  def cantons_raw
    ['aargau', 'appenzell_ausserrhoden', 'appenzell_innerrhoden', 'basel-land', 'basel-stadt', 'bern', 'freiburg', 'genf', 'glarus', 'graubünden', 'jura', 'luzern', 'neuenburg', 'nidwalden', 'obwalden', 'schaffhausen', 'schwyz', 'solothurn', 'st_gallen', 'tessin', 'thurgau', 'uri', 'waadt', 'wallis', 'zug', 'zürich']
  end

  def cantons
    t(cantons_raw, scope: 'defines.cantons')
  end

  def cantons_for_select
    cantons.zip(cantons_raw)
  end

  def genders_raw
    ['male', 'female', 'other']
  end

  def genders
    t(genders_raw, scope: 'defines.genders')
  end

  def genders_for_select
    genders.zip(genders_raw)
  end

end
