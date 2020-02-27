function _hit(dx,dy,r)
  if _gameover then return end
  dx=abs(dx)
  dy=abs(dy)
  if dx>r or dy>r then return end
  dist=sqrt(dx*dx+dy*dy)
  return dist<=r
end

function _new()
  _wavenum=0
  _score=0
  _boost=0
  _blasting=0
  _gameover=false
  _gameovertime=0
  _particles={}
  _player={
    x=0,
    y=0,
    s=0,
    vx=0,
    vy=0
  }
  _stars={}
  _well={x=-99,y=0}
  _comets={}
  for i=1,128 do
    add(_stars,{
      x=rnd(128),
      y=rnd(128),
      z=flr(i/42)+1
    })
  end
  if not _newgame then
    _newwell()
  end
end

function _newwell()
  _well={
    x=_player.x+rnd(512)-256,
    y=_player.y+rnd(512)-256
  }
end

function _wave()
  _wavenum+=1
  _player.s=0
  _immune=45
  _comets={}
  for i=1,_wavenum+1 do
    add(_comets,{
      x=_player.x+rnd(512)-256,
      y=_player.y+rnd(512)-256,
      vx=0,
      vy=0
    })
  end
  add(_comets,_player)
end
