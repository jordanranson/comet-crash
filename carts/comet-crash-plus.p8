pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
_flashn=0
_flash=false
_newgame=true
_instructions=false
_dangern=0
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
  pal(0, 129, 1)
  pal(13, 140, 1)
  pal(5, 13, 1)
  pal(14, 143, 1)
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
    _colors={5,13,1}
    _camera(0,0)
    circ(_x,_y,0,_colors[_star.z])
  end
  srand(time())

  -- input
  _x=.05
  if _gameover or _newgame then
    if _gameovertime>45 then
      if btnp(4) or btnp(5) then
        if _instructions or not _newgame then
          _newgame=false
          _instructions=false
          _new()
          _wave()
          sfx(2)
        elseif _newgame then
          _instructions=true
          sfx(2)
        end
      end
    end
  else
    if btn(0) then _player.vx-=_x end
    if btn(1) then _player.vx+=_x end
    if btn(2) then _player.vy-=_x end
    if btn(3) then _player.vy+=_x end
    if btn(0) or btn(1) or btn(2) or btn(3) then
      sfx(5)
      _color=_ramps[1]
      if _player.s>0 then
        _color=_ramps[2]
      end
      _emit(1,_player.x,_player.y,_player.vx/2,_player.vy/2,_color,10)
    end
    if _player.s>0 and _blasting<1 then
      if btnp(4) or btnp(5) then
        _shake(3)
        _emit(100,_player.x,_player.y,7,7,_ramps[2],50)
        sfx(0)
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
      sfx(1)
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
          sfx(3)
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
            sfx(3)
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
          -- _emit(-1,_comet.x,_comet.y,1,1,{_color},10)
        end
        if _comet==_player and _player.s>0 then
          -- _emit(-1,_comet.x,_comet.y,1,1,{_color},10)
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
    _danger=0
    if not _gameover then
      for i,_comet in pairs(_comets) do
        if i<#_comets then
          _dx=_player.x-_comet.x
          _dy=_player.y-_comet.y
          if abs(_dx)>64
          or abs(_dy)>64 then
            _color=8
            if abs(_dx)<96
            and abs(_dy)<96 then
              if _flash then
                _color=10
              end
              _danger+=1
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
    if _dangern==0 and _danger>0 then
      sfx(4)
    end
    _dangern+=1
    _dangern=_dangern%4

    -- other ui
    if not _newgame then
      print('wave  '.._wavenum,3,3,12)
      print('score '.._score,3,10,12)
    end
    if _newgame and not _instructions then
      _player.vx = -7.5
      _player.vy = 5
    end
    if _gameovertime<100 then _gameovertime+=1 end
    if _gameover and _gameovertime>45 and not _newgame then
      if _flash then print('press z/x',44,61,7) end
    end
    if _newgame and not _instructions then
      -- title particles
      _x=rnd(80)-40
      _y=rnd(20)-10
      _emit(1,_x,_y,1,2,_ramps[4],10)
      -- title comet
      _x=41
      _y=46
      _r=7
      _color=12+rnd(2)
      _color2=7
      circfill(_x,_y,_r+1+rnd(2),_color)
      _vx = -7.5
      _vy = 5
      for i=1,15 do
        _pct=i/(15)
        _x2=_x-_vx*_r*_pct+(rnd(2)-1)
        _y2=_y-_vy*_r*_pct+(rnd(2)-1)
        circfill(
          _x2,
          _y2,
          (1-(_pct))*_r*2,
          _color
        )
      end
      circfill(_x+1,_y-1,_r+rnd(3)-1,_color2)
      -- title
      _titlehueshift()
      _color=9+abs(sin(time()*2))*2
      pal(10,_color)
      _color=8+abs(sin(time()*4))*2
      pal(8,_color)
      sspr(0,32,128,32,0,54)
      pal(10,10)
      pal(8,8)
      if _flash then print('press z/x',46,90,7) end
    end
    if _instructions then
      _player.vx *= 0.95
      _player.vy *= 0.95
      _print('collect pink power-ups|   to get angry and|smash all your enemies',19,44,1)
      _print('collect #pink power-ups|   to get @angry and|smash all your !enemies',19,42,12)
      if _flash then print('press z/x',46,90,7) end
    end
  end
__gfx__
000000000000000000777777776000000000000000000000000000000677780000000000d777200000477777777777a000c77777777777777750000000000000
0000000000000000733444555660000000000000000000000000000006888a0000000000d222300000555666888aaab000ccddd2223334445550000000000000
0000000000000007333444555660000000000000000000000000000006888a7000000007d222300000555666888aaab000ccddd2223334445550000000000000
0000000000000072333444555660000000000000000000000000000006888aa70000007dd222300000555666888aaab000ccddd2223334445550000000000000
000000000000002333444555666000000000000000000000000000000888aaab700007dd22233000005566611111111000cddd22233344455560000000000000
000000000000072333441111111000000000000000000000000000000888aaabb7007ddd22233000005566600000000000111111233341111110000000000000
000000000000022333410000000000000000000000000000000000000888aaabbb77cddd22233000005566600000000000000000233340000000000000000000
00000000000002333410000000000000000000000000000000000000088aaabbbcccddd222333000005666877777b00000000000333440000000000000000000
00000000000002333400000000000000000000000000000000000000088aaabbbcccddd222333000005666888aaab00000000000333440000000000000000000
00000000000002333400000000000000000000000000000000000000088aaabbbcccddd222333000005666888aaab00000000000333440000000000000000000
0000000000000333440000000000000000000000000000000000000008aaab1bcccddd212333400000666888aaabb00000000000334440000000000000000000
0000000000000333440000000000000000000000000000000000000008aaab01cccddd1023334000006668811111100000000000334440000000000000000000
0000000000000333447000000000000000000000000000000000000008aaab001ccdd10023334000006668800000000000000000334440000000000000000000
000000000000033444570000000000000000000000000000000000000aaabb0001dd100033344000006688800000000000000000344450000000000000000000
000000000000013444557777778000000000000000000000000000000aaabb000011000033344000006688800000000000000000344450000000000000000000
000000000000013444555666888000000000000000000000000000000aaabb00000000003334400000668887777777c000000000344450000000000000000000
00000000000000144555666888a000000000000000000000000000000aabbb000000000033444000006888aaabbbccc000000000444550000000000000000000
00000000000000014555666888a000000000000000000000000000000aabbb000000000033444000006888aaabbbccc000000000444550000000000000000000
00000000000000001155666888a000000000000000000000000000000aabbb000000000033444000006888aaabbbccc000000000444550000000000000000000
00000000000000000011111111100000000000000000000000000000011111000000000011111000001111111111111000000000111110000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000002aaaa000000000000000000000000000000000000
00000000000000000000000000000000000000000aaaaaa2000000000000000000000000000000000000000aaaaa000000000000000000000000000000000000
000000000000000000000000000000000000000aaaaaaaaa000000000000000000000000000000000000000aaaa2000000000000000000000000000000000000
00000000000000000000000000000000000000aa8aaa8aaa80000000000000000000000000000000000000aa8aa0000000000000000000000000000000000000
0000000000000000000000000000000000000aaaaaaaaaaaa0000000000000000000000000000000000000aaaa20000000000000000000000000000000000000
0000000000000000000000000000000000008a8aaa8aaa8aa000000000000000000000000000000000000a8aaa00000000000000000000000000000000000000
000000000000000000000000000000000002a8aaaa2aaaaa2000000000000000000000000000000000000aaaaa00000000000000000000000000000000000000
00000000000000000000000000000000000a8a8a80008a8a000a228a8000000022000000002a8a8a00008a8a8200000000000000000000000000000000000000
000000000000000000000000000000000028aaa80000aaa000a8aaa8a20002a8aaa200000aa8aaa82000aaa8a000000000000000000000000000000000000000
00000000000000000000000000000000008a8a8200000000028a8a8a80008a8a8a8a80008a8a8a8a00028a8a8002200000000000000000000000000000000000
0000000000000000000000000000000000a8a8a00000000008a8a8a80008a8a8a8a8a002a8a8a8200008a8a822a8a80000000000000000000000000000000000
00000000000000000000000000000000008a888000000000088a8820008a888a888a800a888a8000000a8a8a288a888000000000000000000000000000000000
0000000000000000000000000000000002a8a8200000000028a8a20002a8a8a8a8a8a008a8a8a8000008a8a8a8a8a8a000000000000000000000000000000000
0000000000000000000000000000000002888a20000000008a8880000a888a828a8880008a888a8000288a888a888a8000000000000000000000000000000000
0000000000000000000000000000000002a8a82000000000a8a8a00008a8a208a8a8a00008a8a8a200a8a8a8a8a8a8a000000000000000000000000000000000
00000000000000000000000000000000028888822888000288882000288820088888200000288888008888888088882000000000000000000000000000000000
000000000000000000000000000000000088a8a8a8880008a888000028a820a8a8a82028a8a8a8a20288a8a80088a82000000000000000000000000000000000
00000000000000000000000000000000008888888888800888880000288888888888228888888882088888820028888000000000000000000000000000000000
00000000000000000000000000000000002888888888000888820000088888a8888888a8888888a0088888800008888000000000000000000000000000000000
00000000000000000000000000000000000088888820000888800000008888820222288888888800008882000000882000000000000000000000000000000000
00000000000000000000000000000000000000000000000020000000000000000000008888880000000000000000000000000000000000000000000000000000
__sfx__
010400001e6721866214662116520e6520c6420a64207642066420563204632046320363203622036220262202622026220262200612006120061200612006120061200612006120061200612006120061500602
010200000047102471044610546107451024510c4710e471104611146113451184511a4711c4711d4611f461244512645128471294712b46130465324553444535435374251b4001d4001f4001b4001b4001f400
010300001b370273661b356273461b336273261b315273151b3050330302304023050130301304013050030300304003050030300304003050030300304003050030500303003040030500305003050030500300
010200001e3731836414365113530e3540c3450a34307344063450533304334043350333303324033250232302324023250232300314003150031300314003150031300314003150031500305003020030200302
010a00001843106415284002840028400284002840028400284002840028400284002840028400284002840028400284002840000405004050040500405004050040500405004050040500405004050040500405
010400002461130615246002460024600246002460024600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600