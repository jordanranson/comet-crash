pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
_flashn=0
_flash=false
_newgame=true
_cam={x=0,y=0}
_scrn={
  x=0,
  y=0,
  vx=0,
  vy=0
}
_ramps={
  {13,12,6},
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
function _init()
  _new()
  _gameover=true
  _gameovertime=100
end

function _draw()
  cls(0)

  -- flash
  _flashn+=1
  if _flashn==2 then
    if _flash then _flash=false
    else _flash=true end
    _flashn=0
  end

  -- screen shake
  _scrn.vx+=-_scrn.x*.4
  _scrn.vy+=-_scrn.y*.4
  _scrn.vx*=.85
  _scrn.vy*=.85
  _scrn.x+=_scrn.vx
  _scrn.y+=_scrn.vy
  if _scrn.vx>-.1 and _scrn.vx<.1
  and _scrn.vy>-.1 and _scrn.vy<.1 then
    _scrn.vx=0
    _scrn.vy=0
  end

  -- stars
  for i,_star in pairs(_stars) do
    _star.x-=_player.vx/_star.z/2
    _star.y-=_player.vy/_star.z/2
    _x=_star.x
    _y=_star.y
    if _star.x<0 then _star.x=127 end
    if _star.x>127 then _star.x=0 end
    if _star.y<0 then _star.y=127 end
    if _star.y>127 then _star.y=0 end
    srand(i)
    _colors={6,13,1}
    _camera(0,0)
    circ(_x,_y,0,_colors[_star.z])
  end
  srand(time())

  -- input
  _x=.05
  if _gameover or _newgame then
    if _gameovertime>45 then
      if btnp(4) then
        _newgame=false
        _new()
        _wave()
      end
    end
  else
    if btn(0) then _player.vx-=_x end
    if btn(1) then _player.vx+=_x end
    if btn(2) then _player.vy-=_x end
    if btn(3) then _player.vy+=_x end
    if _player.s>0 and _blasting<1 then
      if btnp(4) or btnp(5) then
        _shake(3)
        _emit(100,_player.x,_player.y,7,7,_ramps[2],50)
        _blasting=45
        _immune=0
        _player.s=0
        _r=atan2(_player.vx,_player.vy)
        _x=cos(_r)*5
        _y=sin(_r)*5
        if btnp(5) then
          _x*=-1
          _y*=-1
          _player.vx*=-1
          _player.vy*=-1
        end
        _player.vx+=_x
        _player.vy+=_y
      end
    end
  end
  _camera(_player.x-64,_player.y-64)

  -- wells
  circ(_well.x,_well.y,6+rnd(18),13+rnd(3))
  _emit(-1,_well.x,_well.y,.7,.7,{1,2,13,14},50)
  if _flash then
    circfill(_well.x,_well.y,21+rnd(6),rnd(3))
  end
  _dx=_player.x-_well.x
  _dy=_player.y-_well.y
  if _hit(_dx,_dy,23) then
    if _player.s<1 then
      _newwell()
      _shake(2)
      _emit(50,_well.x,_well.y,3,3,{12,15,13,14},30)
      _emit(50,_player.x,_player.y,3,3,{12,15,13,14},30)
      _player.s=1
      _immune=0
    end
  end

  -- particles
  for k,_particle in pairs(_particles) do
    _particle.vx*=.99
    _particle.vy*=.99
    _particle.x+=_particle.vx
    _particle.y+=_particle.vy
    _particle.cur+=1
    if _particle.cur>_particle.life then
      del(_particles,_particle)
    end
    circ(_particle.x,_particle.y,_particle.size,_particle.col)
  end

  -- comets
  for i,_comet in pairs(_comets) do
    _rampi=1
    if _player.s>0 and _blasting<1 then
      _rampi=2
    end
    if _blasting>0 then
      _rampi=2
    end
    _color,_color2=_rndcol(_rampi)
    if _immune>0 and _flash and _blasting<1 then
      _color=0
    end
    -- enemy
    if _comet~=_player then
      _color,_color2=_rndcol(3)
      _len=12
      if not _gameover then
        _dx=_player.x-_comet.x
        _dy=_player.y-_comet.y
        _comet.vx+=_dx*.001
        _comet.vy+=_dy*.001
      end
      -- collision
      _r=0
      if _player.s>0 then _r=2 end
      if _blasting>0 then _r=21 end
      if _hit(_dx,_dy,7+_r) then
        if (_immune<1 and _player.s>0) or _blasting>0 then
          del(_comets,_comet)
          _shake(3)
          _emit(50,_player.x,_player.y,3,3,_ramps[2],30)
          if _blasting<1 then
            _immune=60
            _score+=10
            _player.s=0
          else
            _score+=30
          end
        elseif (not _gameover)
          and _immune<1 then
            _gameover=true
            _gameovertime=0
            _shake(7)
            _emit(90,_player.x,_player.y,3,3,_ramps[1],200)
            _emit(10,_comet.x,_comet.y,3,3,_ramps[3],200)
          end
        end
        _r=1
      -- player
      else
        if _immune>0 then _immune-=1 end
        _r=1+(_player.s/4)
      end
      _comet.vx*=.99
      _comet.vy*=.99
      _comet.x+=_comet.vx
      _comet.y+=_comet.vy
      -- repulsion
      if _comet~=_player then
        for j,_other in pairs(_comets) do
          if _other~=_comet and _other~=_player then
            _dx=_other.x-_comet.x
            _dy=_other.y-_comet.y
            if _hit(_dx,_dy,15) then
              _comet.vx-=_dx*.02
              _comet.vy-=_dy*.02
            end
          end
        end
      end
      -- blasting
      if _comet==_player and _blasting>0 then
        if _flashn%2==0 then
          circfill(_comet.x,_comet.y,16+rnd(6),8+rnd(3))
          circ(_comet.x,_comet.y,6+rnd(18),8+rnd(3))
        end
        _blasting-=1
      end
      if (_comet==_player and not _gameover) or _comet~=_player then
        -- main comet
        circfill(_comet.x,_comet.y,_r+1+rnd(2),_color)
        -- tail
        if abs(_comet.vx)>3.5 or abs(_comet.vy)>3.5 then
          _emit(-1,_comet.x,_comet.y,1,1,{_color},10)
        end
        if _comet==_player and _player.s>0 then
          _emit(-1,_comet.x,_comet.y,1,1,{_color},10)
        end
        for i=1,12 do
          _pct=i/(12)
          _x=_comet.x-_comet.vx*3*_pct+(rnd(2)-1)
          _y=_comet.y-_comet.vy*3*_pct+(rnd(2)-1)
          _pct=_r-_pct
          circfill(_x,_y,_pct*3,_color)
        end
        -- inner comet
        circfill(_comet.x,_comet.y,_r+rnd(2),_color2)
      end
    end
    if #_comets==1 then
      _wave()
    end

    -- indicator ui
    _camera(0,0)
    if not _gameover then
      for i,_comet in pairs(_comets) do
        if i<#_comets then
          _dx=_player.x-_comet.x
          _dy=_player.y-_comet.y
          if abs(_dx)>64
          or abs(_dy)>64 then
            _color=8
            if abs(_dx)<96
            and abs(_dy)<96
            and _flash then
              _color=10
            end
            _r=atan2(_dx,_dy)
            _x=-cos(_r)*50
            _y=-sin(_r)*50
            _dx=-cos(_r)*60
            _dy=-sin(_r)*60
            line(_x+64,_y+64,_dx+64,_dy+64,_color)
          end
        end
      end
      _dx=_player.x-_well.x
      _dy=_player.y-_well.y
      if abs(_dx)>64
      or abs(_dy)>64 then
        _color=14
        if abs(_dx)<96
        and abs(_dy)<96
        and _flash then
          _color=7
        end
        _r=atan2(_dx,_dy)
        _x=-cos(_r)*50
        _y=-sin(_r)*50
        _dx=-cos(_r)*60
        _dy=-sin(_r)*60
        line(_x+64,_y+64,_dx+64,_dy+64,_color)
      end
    end

    -- other ui
    if not _newgame then
      print('wave  '.._wavenum,3,3,12)
      print('score '.._score,3,10,12)
    end
    if _gameovertime<100 then _gameovertime+=1 end
    if _gameover and (_gameovertime>45 or _newgame) then
      print('press z/x',44,61,7)
    end
  end