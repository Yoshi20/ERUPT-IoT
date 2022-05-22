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

  def unaccent(text)
    charactersProcessed = "" # To avoid doing a replace multiple times
    newText = text.downcase
    text = newText # Case statement is expecting lowercase
    text.each_char do |c|
      next if  charactersProcessed.include? c
      replacement = ""
      case c
        when '1'
          replacement = "¹"
        when '2'
          replacement = "²"
        when '3'
          replacement = "³"
        when 'a'
          replacement = "á|à|â|ã|ä|å|ā|ă|ą|À|Á|Â|Ã|Ä|Å|Ā|Ă|Ą|Æ"
        when 'c'
          replacement = "ć|č|ç|©|Ć|Č|Ç"
        when 'e'
          replacement = "è|é|ê|ё|ë|ē|ĕ|ė|ę|ě|È|Ê|Ë|Ё|Ē|Ĕ|Ė|Ę|Ě|€"
        when 'g'
          replacement = "ğ|Ğ"
        when 'i'
          replacement = "ı|ì|í|î|ï|ì|ĩ|ī|ĭ|Ì|Í|Î|Ï|Ї|Ì|Ĩ|Ī|Ĭ"
        when 'l'
          replacement = "ł|Ł"
        when 'n'
          replacement = "ł|Ł"
        when 'n'
          replacement = "ń|ň|ñ|Ń|Ň|Ñ"
        when 'o'
          replacement = "ò|ó|ô|õ|ö|ō|ŏ|ő|ø|Ò|Ó|Ô|Õ|Ö|Ō|Ŏ|Ő|Ø|Œ"
        when 'r'
          replacement = "ř|®|Ř"
        when 's'
          replacement = "š|ş|ș|ß|Š|Ş|Ș"
        when 'u'
          replacement = "ù|ú|û|ü|ũ|ū|ŭ|ů|Ù|Ú|Û|Ü|Ũ|Ū|Ŭ|Ů"
        when 'y'
          replacement = "ý|ÿ|Ý|Ÿ"
        when 'z'
          replacement = "ž|ż|ź|Ž|Ż|Ź"
      end
      if !replacement.empty?
        charactersProcessed = charactersProcessed + c
        newText = newText.gsub(c, "(" + c + "|" + replacement + ")")
      end
    end
    return newText
  end

end
