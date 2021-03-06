addVocabulary

  '⍕': (⍵, ⍺) ->
    if ⍺
      nonceError()
    else
      # ⍕123            ←→ 1 3⍴'123'
      # ⍕123 456        ←→ 1 7⍴'123 456'
      # ⍕123 'a'        ←→ 1 5⍴'123 a'
      # ⍕12 'ab'        ←→ 1 7⍴'12  ab '
      # ⍕1 2⍴'a'        ←→ 1 2⍴'a'
      # ⍕2 2⍴'a'        ←→ 2 2⍴'a'
      # ⍕2 2⍴5          ←→ 2 3⍴('5 5',
      # ...                     '5 5')
      # ⍕2 2⍴0 0 0 'a'  ←→ 2 3⍴('0 0',
      # ...                     '0 a')
      # ⍕2 2⍴0 0 0 'ab' ←→ 2 6⍴('0   0 ',
      # ...                     '0  ab ')
      # ⍕2 2⍴0 0 0 123  ←→ 2 5⍴('0   0',
      # ...                     '0 123')
      # ⍕4 3 ⍴ '---' '---' '---' 1 2 3 4 5 6 100 200 300
      # ...             ←→ 4 17⍴(' ---   ---   --- ',
      # ...                      '   1     2     3 ',
      # ...                      '   4     5     6 ',
      # ...                      ' 100   200   300 ')
      # ⍕1 ⍬ 2 '' 3     ←→ 1 11⍴'1    2    3'
      # ⍕∞              ←→ 1 1⍴'∞'
      # ⍕¯∞             ←→ 1 2⍴'¯∞'
      # ⍕¯1             ←→ 1 2⍴'¯1'
      # ⍕¯1e¯100J¯2e¯99 ←→ 1 14⍴'¯1e¯100J¯2e¯99'
      t = format ⍵
      new A t.join(''), [t.length, t[0].length]

# Format an APL object as an array of strings
format = (a) ->
  if typeof a is 'undefined' then ['undefined']
  else if a is null then ['null']
  else if typeof a is 'string' then [a]
  else if typeof a is 'number' then r = [formatNumber a]; r.align = 'right'; r
  else if typeof a is 'function' then ['#procedure']
  else if !(a instanceof A) then ['' + a]
  else if prod(⍴ a) is 0 then ['']
  else
    sa = ⍴ a
    a = a.toArray()
    if !sa.length then return format a[0]
    nRows = prod sa[...sa.length - 1]
    nCols = sa[sa.length - 1]

    rows = for [0...nRows]
      height: 0
      bottomMargin: 0

    cols = for [0...nCols]
      type: 0 # 0=characters, 1=numbers, 2=subarrays
      width: 0
      leftMargin: 0
      rightMargin: 0

    grid =
      for r, i in rows
        for c, j in cols
          x = a[nCols * i + j]
          box = format x
          r.height = Math.max r.height, box.length
          c.width = Math.max c.width, box[0].length
          c.type = Math.max c.type,
            if typeof x is 'string' and x.length is 1 then 0
            else if !(x instanceof A) then 1
            else 2
          box

    step = 1
    for d in [sa.length - 2..1] by -1
      step *= sa[d]
      for i in [step - 1...nRows - 1] by step
        rows[i].bottomMargin++

    for c, j in cols
      if j isnt nCols - 1 and !(c.type is cols[j + 1].type is 0)
        c.rightMargin++
      if c.type is 2
        c.leftMargin++
        c.rightMargin++

    result = []
    for r, i in rows
      for c, j in cols
        t = grid[i][j]
        if t.align is 'right'
          left = repeat ' ', c.leftMargin + c.width - t[0].length
          right = repeat ' ', c.rightMargin
        else
          left = repeat ' ', c.leftMargin
          right = repeat ' ', c.rightMargin + c.width - t[0].length
        for k in [0...t.length] by 1 then t[k] = left + t[k] + right
        bottom = repeat ' ', t[0].length
        for [t.length...r.height + r.bottomMargin] then t.push bottom
      for k in [0...r.height + r.bottomMargin] by 1
        result.push((for j in [0...nCols] by 1 then grid[i][j][k]).join '')

    result
