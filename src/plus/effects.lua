_cam={x=0,y=0}
_scrn={
  x=0,
  y=0,
  vx=0,
  vy=0
}
_ramps={
  {13,12,7},
  {8,9,10},
  {5,6,7},
  {9,10}
}

function _rndcol(i)
  return _ramps[i][flr(rnd(#_ramps[i]))+1],_ramps[i][#_ramps[i]]
end

function _camera(x,y)
  _cam.x=x
  _cam.y=y
  camera(x+_scrn.x,y+_scrn.y)
end

function _shake(amt)
  _x=1
  if rnd()>.5 then _x=-1 end
  _y=1
  if rnd()>.5 then _y=-1 end
  _scrn.x+=_x*amt
  _scrn.y+=_y*amt
end

function _emit(num,x,y,vx,vy,cols,life,kind)
  if num==-1 and _flash then return end
  if num==-1 then num=1 end
  for i=1,num do
    k=cols[flr(rnd(#cols)+1)]
    _px=1
    if rnd()>.5 then _px=-1 end
    _py=1
    if rnd()>.5 then _py=-1 end
    add(_particles,{
      x=x,
      y=y,
      vx=vx*rnd()*_px,
      vy=vy*rnd()*_py,
      col=k,
      cur=0,
      life=life,
      size=rnd(2),
      kind=kind
    })
  end
end

function _print(chars,x,y,col)
  local _cy=0
  local _cx=0
  local _col=col
  for i=1,#chars do
    local _char=sub(chars,i,i)
    if _char == '|' then
      _cx=0
      _cy+=1
      _col=col
    elseif _char == '!' then
      _col=7
    elseif _char == '@' then
      _col=8
    elseif _char == '#' then
      _col=14
    else
      print(_char,x+(_cx*4),y+(_cy*7)+sin(-time()/2+(_cx*2/#chars))*2,_col)
      _cx+=1
    end
    if _char == ' ' then
      _col=col
    end
  end
end

_titlehue=1
function _titlehueshift()
  _colors={2,3,4,5,6,8,10,11,12,13}
  for i=1,#_colors do
    pal(_colors[i],12)
  end
  _color=_colors[_titlehue]
  pal(_color,7)

  sspr(0,0,128,32,0,37)

  _titlehue+=1
  if _titlehue > #_colors then _titlehue = 1 end

  for i=1,#_colors do
    pal(_colors[i],_colors[i])
  end
end
