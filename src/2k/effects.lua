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
  {5,6,7}
}

function _rndcol(i)
  return _ramps[i][flr(rnd(3))+1],_ramps[i][3]
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
    _x=1
    if rnd()>.5 then _x=-1 end
    _y=1
    if rnd()>.5 then _y=-1 end
    add(_particles,{
      x=x,
      y=y,
      vx=vx*rnd()*_x,
      vy=vy*rnd()*_y,
      col=k,
      cur=0,
      life=life,
      size=rnd(2),
      kind=kind
    })
  end
end
