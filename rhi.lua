local bit32_band, bit32_bxor, bit32_rshift, bit32_lrotate =
    bit32.band, bit32.bxor, bit32.rshift, bit32.lrotate
local __cc20k = {0xB4DCF90F, 0x798341E7, 0x9EBE3BFC, 0x12A01417, 0xA346186C, 0x6B582812, 0xDE053CDC, 0xC07B2719}
local function __cc20_qr(s, a, b, c, d)
    s[a] = bit32_band(s[a] + s[b], 0xFFFFFFFF); s[d] = bit32_bxor(s[d], s[a]); s[d] = bit32_lrotate(s[d], 16)
    s[c] = bit32_band(s[c] + s[d], 0xFFFFFFFF); s[b] = bit32_bxor(s[b], s[c]); s[b] = bit32_lrotate(s[b], 12)
    s[a] = bit32_band(s[a] + s[b], 0xFFFFFFFF); s[d] = bit32_bxor(s[d], s[a]); s[d] = bit32_lrotate(s[d], 8)
    s[c] = bit32_band(s[c] + s[d], 0xFFFFFFFF); s[b] = bit32_bxor(s[b], s[c]); s[b] = bit32_lrotate(s[b], 7)
end
local function __cc20_block(key, counter, nonce)
    local s = {
        0x61707865, 0x3320646e, 0x79622d32, 0x6b206574,
        key[1], key[2], key[3], key[4], key[5], key[6], key[7], key[8],
        counter, nonce[1], nonce[2], nonce[3],
    }
    local w = {}
    for idx = 1, 16 do w[idx] = s[idx] end
    for _ = 1, 10 do
        __cc20_qr(w, 1, 5, 9, 13); __cc20_qr(w, 2, 6, 10, 14)
        __cc20_qr(w, 3, 7, 11, 15); __cc20_qr(w, 4, 8, 12, 16)
        __cc20_qr(w, 1, 6, 11, 16); __cc20_qr(w, 2, 7, 12, 13)
        __cc20_qr(w, 3, 8, 9, 14); __cc20_qr(w, 4, 5, 10, 15)
    end
    local out = {}
    for idx = 1, 16 do out[idx] = bit32_band(w[idx] + s[idx], 0xFFFFFFFF) end
    return out
end
local function __cc20d(cipher, nonce)
    local needed = #cipher
    local keystream = {}
    local counter = 0
    while #keystream < needed do
        local blk = __cc20_block(__cc20k, counter, nonce)
        for idx = 1, 16 do
            local w = blk[idx]
            keystream[#keystream + 1] = bit32_band(w, 0xFF)
            keystream[#keystream + 1] = bit32_band(bit32_rshift(w, 8), 0xFF)
            keystream[#keystream + 1] = bit32_band(bit32_rshift(w, 16), 0xFF)
            keystream[#keystream + 1] = bit32_band(bit32_rshift(w, 24), 0xFF)
        end
        counter = counter + 1
    end
    local chars = {}
    for idx = 1, needed do
        chars[idx] = string.char(bit32_bxor(cipher[idx], keystream[idx]))
    end
    return table.concat(chars)
end
if not shared then
return warn(__cc20d({225,35,253,244,176,44,123,164,187,133,80,92,32,73,4,66,2,63,132,222,214},{0xA92A1909,0xF5A726F2,0x5C370CBA}))
end
local TriggerBot={}
local L={}
local U={}
local MENU_KEY=Enum.KeyCode.RightShift
local MAX_WALL_STEPS=6
local SEE_THROUGH_TRANSPARENCY=0.9
local KEY_HOLD_TIME=0.05
local AIM_DEADZONE=2
local ASSIST_REACQUIRE_DELAY=0.4
local FULLBRIGHT_AMBIENT=Color3.fromRGB(178,178,178)
local FULLBRIGHT_CLOCK_TIME=14
local DEFAULT_GRAVITY=196.2
local BULLET_TRACER_LIFETIME=0.12
local CONFIG_DIR=__cc20d({57,12,62,95,104,165,178,131,245,123},{0xFAA15526,0x7ED827C1,0x9AB3173F})
local CONFIG_NAME_LENGTH=40
local LUA_FOLDER=__cc20d({214,137,82,48,115,170,85,111,149,45,193,185,123,221},{0xD011131A,0x3491A65B,0x9CE8F0C3})
local LUA_EXTENSION=__cc20d({239,213,209,71},{0x2CEF0393,0xC9E59A7D,0x9940A319})
local TEAM_KEYS={__cc20d({144,96,248,230},{0x0B04493A,0xFA72DC97,0x656000C0}),__cc20d({63,79,44,42,155,191,8,80},{0x24D4436E,0xCE97FE77,0x7F3E5610}),__cc20d({199,237,230,90,104,188},{0x97D35A95,0x5CE6148B,0x512A9A54}),__cc20d({24,231,65,185,222,98},{0xD296D725,0xF4E2C1DE,0x38E561F7}),__cc20d({85,150,186,4,192,103,103,126,138},{0x5FD7E770,0x7B78EA63,0xF083E02C}),__cc20d({164,235,105,180},{0xB0D68D6E,0xA375A657,0x8AC12DE7}),__cc20d({168,139,163,238,45,53,47},{0x8855FE43,0x4ED7B9FB,0x1A826208}),__cc20d({199,29,46,241,6},{0x49FEA3F1,0xFCFB093E,0xAB307AE9}),__cc20d({97,245,163,57,233},{0xDEF9EFBD,0x20A851B4,0x78504D57})}
local UPDATE_BIND_NAME=__cc20d({199,193,206,156,23,173,74,241,96,84,100,94,68,199,198,218},{0xEEDB0CB0,0x9493B54D,0x9F6EF60D})
local UPDATE_RENDER_PRIORITY=Enum.RenderPriority.Camera.Value+1
local SPIN_BIND_NAME=__cc20d({37,211,133,212,171,239,160,86,52,58,221,82,141,227,103,41,68,159,232,0,158},{0xC2CC263A,0xD9DB39C2,0x8B45B7C0})
local CAMERA_RESTORE_BIND_NAME=__cc20d({207,182,45,73,147,177,93,73,235,97,66,31,59,244,144,85,60,171,91,247,96,73,148},{0xA5578089,0x1B2BDDBF,0x5357AE14})
local CAMERA_APPLY_BIND_NAME=__cc20d({165,148,245,198,124,209,15,21,156,68,85,12,92,121,144,57,212,128,96,135,230},{0x261A2CBE,0xE0012374,0x628025C1})
local RESTORE_RENDER_PRIORITY=Enum.RenderPriority.First.Value
local CAMERA_APPLY_PRIORITY=Enum.RenderPriority.Last.Value
local SILENT_WINDOW=0.25
local SILENT_MIN_RANGE=60
local SILENT_MIN_DOT=0.85
local BODY_PART_NAMES={
Head=true,Torso=true,UpperTorso=true,LowerTorso=true,
[__cc20d({118,221,139,186,203,192,35,2},{0x2A3E3441,0xC0E8421D,0x3FDC683C})]=true,[__cc20d({111,109,255,71,8,147,254,16,138},{0x2DADFC03,0x99D0C886,0x251A7F25})]=true,[__cc20d({118,104,251,144,168,203,225,149},{0x54F3A67C,0xE5C26DE0,0xA08C2C17})]=true,[__cc20d({43,147,214,188,95,21,208,15,19},{0x828A0F86,0x35EA5953,0x95F370C7})]=true,
LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,
RightUpperArm=true,RightLowerArm=true,RightHand=true,
LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,
RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,
}
local playersService=game:GetService(__cc20d({153,17,110,113,225,40,18},{0x16B1F574,0x811EEB3F,0x39A2F43A}))
local runService=game:GetService(__cc20d({218,194,176,3,93,148,203,175,204,230},{0xC1144AA3,0xDBE3CA7D,0xDB390E0B}))
local userInputService=game:GetService(__cc20d({188,91,152,138,69,11,175,162,3,231,218,113,130,91,17,252},{0xEBD77B0D,0x66B62A3E,0xC958B482}))
local coreGuiService=game:GetService(__cc20d({64,152,43,182,68,184,33},{0xADC473D9,0x85F21EA2,0xA5DDECA1}))
local lightingService=game:GetService(__cc20d({134,193,101,149,111,4,34,185},{0x7BC8424A,0xCD979A97,0xAA7DF246}))
local httpService=game:GetService(__cc20d({175,229,244,159,50,35,254,61,92,177,31},{0x7B48D1EE,0xAD3D1FD0,0xBD0F70C0}))
local workspaceService=workspace
local TweenService=game:GetService(__cc20d({203,156,122,99,237,36,104,36,159,173,254,42},{0x1160E7EC,0x0F9CCB3B,0x8893642A}))
local Players=playersService
local UIS=userInputService
local HttpService=httpService
local localPlayer=playersService.LocalPlayer
local currentCamera=workspace.CurrentCamera
local lastClick=0
local pending=false
local connections={}
local window=nil
local MODES={__cc20d({69,21,203,167,80,250},{0xA337825D,0xBFEBC6F0,0x8C7176A1}),__cc20d({23,80,233,53},{0x02252C54,0x34302FA0,0x4464DA6F}),__cc20d({115,1,129,140,54,155},{0x3073E39F,0xEF3D980D,0x3BB3CC42})}
local FIRE_STYLES={__cc20d({45,83,36,156,186},{0xCCD114EE,0x3418B861,0x3F9B8469}),__cc20d({75,131,93,190},{0xFB1315A1,0x4CCDB273,0xBF42A05E})}
local AIM_MODES={__cc20d({130,246,94,252,33,12},{0x4F3E6E67,0xE4EC14B5,0xB64F3B48}),__cc20d({177,97,171,147,113,22},{0x7AF574F9,0x27F78C9C,0x1A0A23B1})}
local AIM_PARTS={__cc20d({134,162,214,198},{0x9D028DB8,0x654F11E4,0x9F0BFA02}),__cc20d({160,159,24,193,65},{0x227268C0,0x2F37B165,0x36472DAB})}
local SPIN_MODES={__cc20d({127,160,80,142},{0x54E8056A,0x4DAE8E6D,0x6E63FC63}),__cc20d({61,157,168,118,161,183},{0x745926F6,0xEEB4C22B,0xC229C265}),__cc20d({135,71,118,93,79,66,150,173,3},{0x61513DE7,0x690B1A84,0x4B799207}),__cc20d({126,1,45,153,138,9},{0x84DCB5C4,0xD620D94D,0x69188B82}),__cc20d({24,35,128,245,218,229},{0xA895BA30,0x93250C61,0x91DC8487})}
local RAGE_MODES={__cc20d({186,128,194,39},{0x16B6B8A5,0xC221F99B,0x1B6EB714}),__cc20d({165,112,68,140,8,178},{0xFC68ACFD,0x3FE83DD5,0xB470A20A})}
local toggled=true
local held=false
local aimHeld=false
local ignoreInputUntil=0
local statusLabel=nil
local holding=false
local holdBind=nil
local lastTargetSeen=0
local botShotUntil=0
local recoilStart=nil
local recoilRemainder=Vector2.zero
local spinAngle=0
local spinRoot=nil
local spinReal=nil
local spinApplied=false
local spinOffset=CFrame.identity
local spinTargetAngle=0
local spinRandomUntil=0
local rageTarget=nil
local rageEngaged=false
local rageRemainder=Vector2.zero
local lastRageShot=0
local silentTarget=nil
local silentUntil=0
local silentHookFailed=false
local cameraObject=nil
local cameraReal=nil
local viewRoot=nil
local viewReal=nil
local bodySaved={}
local thirdPersonCheckbox=nil
local flyCheckbox=nil
local espObjects={}
local fovCircle=nil
local chamObjects={}
local bulletTracers={}
local assistTarget=nil
local assistReleasedUntil=0
local assistRemainder=Vector2.zero
local assistCircle=nil
local selectedLua=__cc20d({173,213,8,234,177,68,54},{0x102D07F8,0x040F8BC4,0xD2887B09})
local luaMessage=__cc20d({},{0xF2E7514A,0xA88758CA,0xB9E760EA})
local luaNameBox=nil
local luaCodeBox=nil
local luaStatusLabel=nil
local manualTeammates={}
local savedLighting=nil
local savedAtmospheres={}
local savedGravity=nil
local currentSpeedBoost=0
local ESP_COLORS={
Red=Color3.fromRGB(255,60,60),
Green=Color3.fromRGB(70,230,110),
Blue=Color3.fromRGB(80,150,255),
Yellow=Color3.fromRGB(255,220,70),
Purple=Color3.fromRGB(180,110,255),
White=Color3.fromRGB(255,255,255),
}
local ESP_COLOR_NAMES={__cc20d({0,47,137},{0xB90FBA32,0xD09E0A34,0xC546DC51}),__cc20d({128,202,57,22,245},{0x0C150105,0x6839DB98,0xB46952CD}),__cc20d({94,85,68,217},{0x4E0E5D4B,0xB89CBC1A,0xAE5EB0F3}),__cc20d({239,159,35,144,248,33},{0x69DECBB5,0xAF434919,0x056D2FBC}),__cc20d({202,190,48,18,129,108},{0x84B02C8A,0x27F29A24,0x8272B03E}),__cc20d({88,52,151,128,42},{0x50B49C6E,0x7F4AB394,0xDD6EDE4A})}
local TEAM_COLOR=Color3.fromRGB(80,200,120)
local Config={
enabled=true,teamCheck=true,wallCheck=true,mode=__cc20d({125,103,112,97,154,119},{0x48FF6255,0x3D4F513A,0x921DF1FA}),
fireStyle=__cc20d({34,138,16,93,244},{0x8FFBE959,0x0C89F823,0xA78F7661}),holdRelease=80,aimAt=__cc20d({60,131,254,66,87,36},{0xF0E6CC7F,0x5ECFB3EE,0x6EF22DBE}),
bind={kind=__cc20d({199,154,115,33,224,41,158},{0x6988E706,0xD8F4D6E2,0xF77A78DD}),code=Enum.KeyCode.RightAlt},
fireBind={kind=__cc20d({171,48,133,135,33,16,128,98,81,244,189,53,36},{0x62354447,0x00C39305,0x643EB680}),code=Enum.UserInputType.MouseButton1},
maxDistance=500,reactionDelay=50,clickCooldown=120,
aimEnabled=false,
aimBind={kind=__cc20d({179,230,177,135,222,20,122,60,92,254,33,102,104},{0xEFC87DF8,0xDACEB8CD,0x2998FF5D}),code=Enum.UserInputType.MouseButton2},
aimPart=__cc20d({118,126,229,117},{0x764900F5,0x39FBBBFC,0xCE6859BD}),aimFov=120,aimSmoothing=6,aimDistance=500,
aimShowFov=true,aimVisibleCheck=true,
assistEnabled=false,assistTeamCheck=true,assistRadius=80,
assistBreakRadius=160,assistStrength=12,assistDistance=500,
assistVisibleCheck=true,assistShowRadius=false,
recoilEnabled=false,recoilManual=true,recoilBot=true,
recoilY=4,recoilX=0,recoilRamp=100,
spinEnabled=false,spinMode=__cc20d({32,41,146,85},{0x097ECD3B,0xF9528D35,0x4CAE11DC}),spinSpeed=1080,spinJitter=180,
spinPauseOnShoot=true,spinShowLocal=true,spinLeanPitch=0,spinLeanRoll=0,
spinStaticAngle=180,spinRandomInterval=400,spinAutoDirection=false,spinSmoothing=120,
rageEnabled=false,rageMode=__cc20d({242,4,87,163},{0x5586FA40,0x7163F905,0xB4C3D9BB}),rageTeamCheck=true,rageWallCheck=true,
rageWallbang=false,ragePart=__cc20d({199,194,149,123},{0x9A0ADBE8,0xC2C49F3B,0x0D9C72F9}),rageDistance=150,rageDelay=100,
rageSnap=50,rageTolerance=12,rageBulletTracer=true,
espEnabled=false,espBoxes=true,espNames=true,espHealth=true,
espDistanceText=true,espTracers=false,espHideTeam=true,
espColor=__cc20d({50,56,247},{0x20097D10,0x58DD6B2B,0xAE838B7C}),espDistance=1000,
chamsEnabled=false,chamsHideTeam=true,chamsThroughWalls=true,
chamsRed=255,chamsGreen=60,chamsBlue=60,chamsFillTransparency=0.5,
chamsOutline=true,chamsOutlineTransparency=0.2,chamsDistance=1000,chamsShowSelf=true,
fbEnabled=false,fbBrightness=2,fbDaytime=true,fbNoShadows=true,fbNoFog=true,
thirdPersonEnabled=false,thirdPersonBind=nil,thirdPersonDistance=12,thirdPersonShowBody=true,
speedEnabled=false,speedValue=30,speedAccelEnabled=false,speedAccelRate=40,
flyEnabled=false,flyBind=nil,flySpeed=50,
lowGravityEnabled=false,lowGravityScale=0.4,
bhopEnabled=false,
smartTeam=true,markBind=nil,
luaAutorunEnabled=false,luaAutorunName=__cc20d({},{0x5AD004EE,0x814B38B7,0x4B3F082A}),
}
local rayParams=RaycastParams.new()
local cameraRayParams=RaycastParams.new()
local wallbangParams=RaycastParams.new()
wallbangParams.FilterType=Enum.RaycastFilterType.Include
cameraRayParams.FilterType=Enum.RaycastFilterType.Exclude
local MOUSE_NAMES={
[Enum.UserInputType.MouseButton1]=__cc20d({117,119},{0xC18F2B87,0x154C6D56,0x97EE22AC}),
[Enum.UserInputType.MouseButton2]=__cc20d({253,177},{0x4F36C9FD,0x542EE6FC,0xFF1D1F84}),
[Enum.UserInputType.MouseButton3]=__cc20d({11,178},{0x9ADCE698,0xDE39E5EA,0x21083976}),
}
L.toBind=function(input)
if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode~=Enum.KeyCode.Unknown then
return{kind=__cc20d({46,118,208,69,221,169,127},{0x36330259,0xA098BF28,0x182495C0}),code=input.KeyCode}
end
if MOUSE_NAMES[input.UserInputType]then
return{kind=__cc20d({247,138,143,144,90,0,15,234,90,151,63,64,85},{0xC046FAFF,0x16A85955,0xE8A9E9A9}),code=input.UserInputType}
end
return nil
end
L.bindName=function(bind)
if not bind then return __cc20d({6,235,115,195},{0x7AF533C1,0x70935801,0xB57622F3})end
if bind.kind==__cc20d({94,4,215,232,216,212,146,104,68,91,205,179,65},{0xF29415F6,0xDCC58648,0x0E80E0B7})then return MOUSE_NAMES[bind.code]end
return bind.code.Name
end
L.matchesBind=function(bind,input)
if not bind then return false end
if bind.kind==__cc20d({178,61,143,155,53,140,46},{0xB2C878C8,0xCA5918AE,0xA297618A})then
return input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==bind.code
end
return input.UserInputType==bind.code
end
L.encodeBind=function(bind)
if not bind then return false end
return{kind=bind.kind,name=bind.code.Name}
end
L.decodeBind=function(data)
if type(data)~=__cc20d({240,222,19,35,24},{0x95CFBA73,0x38E3DD83,0x77E504C0})or type(data.name)~=__cc20d({101,119,157,63,35,141},{0x4839A7D8,0x8260C032,0x9CADE514})then return nil end
local enum=nil
if data.kind==__cc20d({115,74,46,89,234,247,25},{0xE3CBE089,0x252CE756,0xA337D206})then enum=Enum.KeyCode
elseif data.kind==__cc20d({176,7,174,148,84,84,0,184,222,220,248,170,156},{0x12694499,0x9707CC80,0x51649D92})then enum=Enum.UserInputType
else return nil end
local success,code=pcall(function()return enum[data.name]end)
if not success or typeof(code)~=__cc20d({146,154,165,151,93,146,22,117},{0xE6BDD595,0xB59964A5,0xEF68A1FC})then return nil end
return{kind=data.kind,code=code}
end
local T={
bg=Color3.fromRGB(37,36,48),
panel=Color3.fromRGB(44,43,57),
field=Color3.fromRGB(30,29,40),
line=Color3.fromRGB(58,57,73),
text=Color3.fromRGB(238,237,243),
sub=Color3.fromRGB(150,148,166),
accent=Color3.fromRGB(255,124,106),
accent2=Color3.fromRGB(255,178,122),
green=Color3.fromRGB(132,222,152),
yellow=Color3.fromRGB(255,208,120),
blue=Color3.fromRGB(96,144,255),
white=Color3.fromRGB(255,255,255),
}
local F={bold=Enum.Font.GothamBold,med=Enum.Font.GothamMedium,reg=Enum.Font.Gotham}
U.new=function(class,props,parent)
local inst=Instance.new(class)
for k,v in pairs(props or{})do inst[k]=v end
if parent then inst.Parent=parent end
return inst
end
U.corner=function(inst,r)
return U.new(__cc20d({125,178,56,166,62,226,38,218},{0xDD0EF0BD,0xD0006C8F,0xCF581DB2}),{CornerRadius=UDim.new(0,r)},inst)
end
U.stroke=function(inst,color,thick,trans)
return U.new(__cc20d({109,229,168,162,175,72,52,229},{0xD1E2FF1D,0xAEF8EDDB,0x9B07C37D}),{
Color=color or T.line,Thickness=thick or 1,Transparency=trans or 0,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
},inst)
end
U.gradient=function(inst,c1,c2,rot)
return U.new(__cc20d({90,83,183,3,64,216,183,49,12,86},{0x5ABCBBC5,0x97C947BF,0x18D167B4}),{Color=ColorSequence.new(c1,c2),Rotation=rot or 0},inst)
end
U.order=function(inst)
local p=inst.Parent
if p then
local n=0
for _,ch in ipairs(p:GetChildren())do
if ch:IsA(__cc20d({112,90,156,104,93,64,131,127,193},{0x6557D65C,0x0D127EA2,0xB5CA6E49}))then n+=1 end
end
inst.LayoutOrder=n
end
return inst
end
U.raise=function(inst,z)
for _,d in ipairs(inst:GetDescendants())do
if d:IsA(__cc20d({155,110,86,214,244,149,140,18,132},{0x9F29C762,0x04A95A8F,0xA576376B}))then d.ZIndex=z end
end
end
U.sublabel=function(parent,text)
local l=U.new(__cc20d({202,28,85,53,25,245,109,180,78},{0x2E96928C,0x36D4DF9F,0x53E37D9E}),{
Text=text,Font=F.reg,TextSize=12,TextColor3=T.sub,
BackgroundTransparency=1,Size=UDim2.new(1,0,0,14),
TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
},parent)
return U.order(l)
end
U.chevron=function(parent,color,rotation,scale)
local w=8*(scale or 1)
local c=U.new(__cc20d({19,139,10,6,43},{0x69E36B7A,0xB13F83F9,0x76B74AE8}),{
Size=UDim2.fromOffset(w,w),BackgroundTransparency=1,
AnchorPoint=Vector2.new(0.5,0.5),
},parent)
local function bar(ox,rot)
U.new(__cc20d({166,143,190,112,77},{0x91E9244F,0x4A26E566,0x7E385080}),{
Size=UDim2.fromOffset(w*0.55,1.3),BackgroundColor3=color,
BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0.5,ox,0.5,0),Rotation=rot,
},c)
end
bar(-w*0.18,45)
bar(w*0.18,-45)
c.Rotation=rotation or 0
return c
end
U.drawCheck=function(parent,color)
local c=U.new(__cc20d({146,2,9,201,23},{0xE145CAA5,0x63A28217,0x10BDFAEB}),{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},parent)
U.new(__cc20d({118,56,0,58,22},{0xB1A3F4A8,0x1DE737DB,0x94179D9A}),{
Size=UDim2.fromOffset(5,1.6),BackgroundColor3=color,BorderSizePixel=0,
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,-2.5,0.5,2),Rotation=45,
},c)
U.new(__cc20d({219,133,84,2,47},{0xB2985EAE,0xC30B10F0,0x7EE16833}),{
Size=UDim2.fromOffset(9,1.6),BackgroundColor3=color,BorderSizePixel=0,
AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,1.5,0.5,-1),Rotation=-50,
},c)
return c
end
local Flags,Defaults,Setters={},{},{}
local function register(id,default,setter)
Flags[id]=default
Defaults[id]=default
Setters[id]=setter
end
local gui=Instance.new(__cc20d({194,111,210,17,156,6,56,42,168},{0x3F9D1863,0xCE37781A,0x9FC4AEA4}))
gui.Name=__cc20d({241,141,207,145,112,181,164,28,38,180,247,3,57},{0xE8AEF197,0x53441AB4,0x15866C3B})
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.ZIndexBehavior=Enum.ZIndexBehavior.Global
gui.DisplayOrder=999
local parentOk=pcall(function()
gui.Parent=(gethui and gethui())or coreGuiService
end)
if not parentOk then gui.Parent=Players.LocalPlayer:WaitForChild(__cc20d({85,7,135,22,53,171,179,36,104},{0xAC453706,0xC5892092,0xE2712EE8}))end
local unloaded=false
local W,H=620,640
local shadow=U.new(__cc20d({3,0,180,196,78},{0x6EF0D1F4,0xF827E067,0xCED1DB5E}),{
Size=UDim2.new(1,14,1,14),Position=UDim2.fromOffset(-7,-7),
BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.75,
BorderSizePixel=0,ZIndex=0,
},nil)
U.corner(shadow,18)
local mainFrame=U.new(__cc20d({244,23,135,31,6},{0x741EB976,0x4E9DD8BE,0x07EF2D66}),{
Size=UDim2.fromOffset(W,H),BackgroundColor3=T.bg,BorderSizePixel=0,ZIndex=1,
},gui)
U.corner(mainFrame,10)
U.stroke(mainFrame,T.line,1,0.5)
shadow.Parent=mainFrame
local uiScale=U.new(__cc20d({90,151,208,217,210,17,105},{0x9AEC87D9,0xDC3534B6,0xAB4E5EA3}),{Scale=1},mainFrame)
local header=U.new(__cc20d({106,172,8,215,10},{0x9528B633,0x71D74BF9,0x51738C3C}),{
Size=UDim2.new(1,0,0,40),BackgroundColor3=T.accent,
BorderSizePixel=0,ZIndex=2,ClipsDescendants=false,
},mainFrame)
U.corner(header,10)
U.gradient(header,T.accent,T.accent2,0)
local hcover=U.new(__cc20d({81,121,45,19,162},{0x8065C1C1,0x8B68B3FF,0xB17CAADF}),{
Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,28),
BackgroundColor3=T.accent,BorderSizePixel=0,ZIndex=2,
},header)
U.gradient(hcover,T.accent,T.accent2,0)
do
local rng=Random.new(11)
for i=1,30 do
local x,y=rng:NextNumber(0.02,0.98),rng:NextNumber(0.12,0.84)
if i%3==0 then
local s=rng:NextInteger(5,9)
local c=U.new(__cc20d({35,220,189,184,6},{0x7C29B402,0xDCD4FBA2,0x2A8C447E}),{
Size=UDim2.fromOffset(s,s),Position=UDim2.new(x,0,y,0),
BackgroundTransparency=1,ZIndex=2,
},header)
U.new(__cc20d({254,241,160,73,201},{0xA5A1870E,0x6A9755F3,0x2E7D2B6F}),{
Size=UDim2.new(1,0,0.14,0),Position=UDim2.new(0,0,0.5,-0.5),
BackgroundColor3=T.white,BackgroundTransparency=0.3,BorderSizePixel=0,
},c)
U.new(__cc20d({88,29,46,72,71},{0x4C4F9366,0xF98C9A01,0x3DE5B3B9}),{
Size=UDim2.new(0.14,0,1,0),Position=UDim2.new(0.5,-0.5,0,0),
BackgroundColor3=T.white,BackgroundTransparency=0.3,BorderSizePixel=0,
},c)
c.Rotation=rng:NextNumber(0,90)
else
local s=rng:NextInteger(2,4)
local d=U.new(__cc20d({219,57,236,80,119},{0x2834053B,0x63FE02EC,0x47A36321}),{
Size=UDim2.fromOffset(s,s),Position=UDim2.new(x,0,y,0),
BackgroundColor3=T.white,BackgroundTransparency=rng:NextNumber(0.35,0.8),
BorderSizePixel=0,ZIndex=2,
},header)
U.corner(d,s)
end
end
for _=1,7 do
U.new(__cc20d({79,100,160,152,28},{0x8F1004CB,0x8BC5ABCA,0x525291AB}),{
Size=UDim2.fromOffset(rng:NextInteger(40,150),1),
Position=UDim2.new(rng:NextNumber(0.02,0.85),0,rng:NextNumber(0.15,0.8),0),
BackgroundColor3=T.white,BackgroundTransparency=0.86,
BorderSizePixel=0,Rotation=-12,ZIndex=2,
},header)
end
end
local dragSurface=U.new(__cc20d({178,163,251,175,199,86,22,223,42,107},{0xE9DF7D81,0xF5E1B67A,0xB04082A2}),{
Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=__cc20d({},{0xE006D82F,0xDAA31DC6,0x3B32B880}),
AutoButtonColor=false,ZIndex=3,
},header)
U.new(__cc20d({240,85,5,66,202,254,213,92,144},{0x0E29B10B,0xE187D196,0xC9B64438}),{
Text=__cc20d({102,70,75,143,158,129},{0xCE75311B,0xBB156F39,0x9A0074B7}),Font=F.bold,TextSize=16,TextColor3=T.white,
BackgroundTransparency=1,Position=UDim2.new(0,16,0,0),
Size=UDim2.new(0,140,1,0),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
},header)
local iconHost=U.new(__cc20d({19,180,100,111,73},{0x0B7BB72C,0xE5F38911,0xE0650F62}),{
Size=UDim2.new(0,340,1,0),Position=UDim2.new(1,-14,0,0),
AnchorPoint=Vector2.new(1,0),BackgroundTransparency=1,ZIndex=5,
},header)
U.new(__cc20d({83,81,106,217,178,3,96,31,68,105,125,172},{0xFF61A522,0xB1630EF4,0x71E44FFD}),{
FillDirection=Enum.FillDirection.Horizontal,
HorizontalAlignment=Enum.HorizontalAlignment.Right,
VerticalAlignment=Enum.VerticalAlignment.Center,
Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,
},iconHost)
local footer=U.new(__cc20d({233,95,2,239,86},{0x6DE5ACF3,0x459B5DF9,0x93A78306}),{
Size=UDim2.new(1,0,0,50),Position=UDim2.new(0,0,1,-50),
BackgroundTransparency=1,ZIndex=2,
},mainFrame)
U.new(__cc20d({251,133,43,79,66},{0x103F4DFA,0xB830CE2D,0x853DA81D}),{
Size=UDim2.new(1,0,0,1),BackgroundColor3=T.line,
BackgroundTransparency=0.5,BorderSizePixel=0,
},footer)
local avatar=U.new(__cc20d({166,210,206,254,212},{0xDDF92A0B,0x8B46D5D7,0x7DF28B0C}),{
Size=UDim2.fromOffset(20,20),Position=UDim2.fromOffset(16,15),
BackgroundColor3=T.accent,BorderSizePixel=0,
},footer)
U.corner(avatar,10)
U.gradient(avatar,T.accent,T.accent2,30)
U.new(__cc20d({60,118,89,54,255,194,112,101,193},{0x0593AC9B,0xB5D98F05,0x2F95770B}),{
Text=__cc20d({198},{0x46AE68D0,0x00159F74,0xCD33788D}),Font=F.bold,TextSize=11,TextColor3=T.white,
BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
},avatar)
U.new(__cc20d({21,85,131,172,204,130,43,160,31},{0x6B341588,0x9D417E7F,0x0218C6C5}),{
Text=__cc20d({62,48,73,45,186,173,33,150,219,59,24,149,134,29,123,118,175,58,195,177,246,27,158,230,156,108,1},{0x505BE51B,0x0960170D,0x6254754B}),RichText=true,Font=F.med,
TextSize=12,TextColor3=T.text,BackgroundTransparency=1,
Position=UDim2.fromOffset(44,15),Size=UDim2.new(0,220,0,20),
TextXAlignment=Enum.TextXAlignment.Left,
},footer)
local contentHost=U.new(__cc20d({112,58,29,182,182},{0x0824FBA6,0xBBC2AFF4,0x2EDDDC54}),{
Size=UDim2.new(1,-24,1,-98),Position=UDim2.new(0,12,0,48),
BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2,
},mainFrame)
local overlay=U.new(__cc20d({59,166,236,188,75},{0xE9C04CF2,0x7537515B,0xE0A5DD85}),{
Size=UDim2.fromOffset(0,0),BackgroundTransparency=1,
ClipsDescendants=false,ZIndex=400,
},mainFrame)
local activeList,activeField
U.closeDropdown=function()
if activeList then activeList:Destroy()end
activeList,activeField=nil,nil
end
U.openList=function(field,options,onPick)
U.closeDropdown()
local sc=mainFrame.AbsoluteSize.X/W
local rel=field.AbsolutePosition-mainFrame.AbsolutePosition
local w=field.AbsoluteSize.X/sc
local h=#options*21+8
local x=rel.X/sc
local y=rel.Y/sc+field.AbsoluteSize.Y/sc+2
if y+h>H then y=rel.Y/sc-h-2 end
local list=U.new(__cc20d({35,116,239,131,218},{0xDD363EEE,0xB123A50D,0x878FB227}),{
Size=UDim2.fromOffset(w,h),Position=UDim2.fromOffset(x,y),
BackgroundColor3=T.panel,BorderSizePixel=0,ZIndex=500,
},overlay)
U.corner(list,6)
U.stroke(list,T.line,1,0.2)
U.new(__cc20d({205,115,189,220,230,181,39,198,246},{0xD0D99FF0,0xBAB513DE,0xCB31EF03}),{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},list)
U.new(__cc20d({243,57,57,168,229,31,122,241,239,45,11,74},{0x7F7FA72C,0x66CF6490,0x1DC86387}),{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder},list)
for i,opt in ipairs(options)do
local o=U.new(__cc20d({216,160,238,156,239,198,178,46,233,94},{0x76B5D873,0x51F1A0D0,0xDD97E4C8}),{
Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,
Text=opt,Font=F.med,TextSize=13,TextColor3=T.text,
TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,
LayoutOrder=i,ZIndex=501,
},list)
U.new(__cc20d({174,204,120,205,216,21,29,141,84},{0x85A894E1,0x896D4683,0xD7A4A528}),{PaddingLeft=UDim.new(0,8)},o)
o.MouseEnter:Connect(function()o.BackgroundTransparency=0.9 end)
o.MouseLeave:Connect(function()o.BackgroundTransparency=1 end)
o.MouseButton1Click:Connect(function()
onPick(opt)
U.closeDropdown()
end)
end
activeList,activeField=list,field
end
UIS.InputBegan:Connect(function(input)
if not activeList or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
local p=input.Position
local ap,as=activeList.AbsolutePosition,activeList.AbsoluteSize
if p.X>=ap.X and p.X<=ap.X+as.X and p.Y>=ap.Y and p.Y<=ap.Y+as.Y then return end
local fp,fs=activeField.AbsolutePosition,activeField.AbsoluteSize
if p.X>=fp.X and p.X<=fp.X+fs.X and p.Y>=fp.Y and p.Y<=fp.Y+fs.Y then return end
U.closeDropdown()
end)
local activeCapture=nil
UIS.InputBegan:Connect(function(input)
if not activeCapture then return end
local cap=activeCapture
activeCapture=nil
cap(input)
end)
U.checkbox=function(parent,id,label,default,opts)
opts=opts or{}
local row=U.new(__cc20d({200,105,82,166,251},{0xFD0B001B,0x44E6D57D,0xFDA2DFCC}),{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},parent)
U.order(row)
local box=U.new(__cc20d({211,15,150,244,135,132,227,219,121,193},{0xDC69FBA5,0x756AD607,0xB426A39A}),{
Size=UDim2.fromOffset(16,16),Position=UDim2.new(0,0,0.5,-8),
BackgroundColor3=T.field,Text=__cc20d({},{0x2B607AFA,0x0B172DA6,0x8D792CA9}),AutoButtonColor=false,
},row)
U.corner(box,4)
local st=U.stroke(box,T.line,1,0.2)
local check=U.drawCheck(box,T.white)
local lbl=U.new(__cc20d({184,158,144,58,233,202,154,90,137},{0x2F18A539,0x911CD70E,0x8EFD0394}),{
Text=label,Font=F.med,TextSize=13,TextColor3=T.text,
BackgroundTransparency=1,Position=UDim2.new(0,24,0,0),
Size=UDim2.new(1,-24,1,0),
TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
},row)
local value=default and true or false
local function paint()
box.BackgroundColor3=value and T.accent or T.field
st.Transparency=value and 1 or 0.25
check.Visible=value
end
local function set(v)
value=v and true or false
Flags[id]=value
paint()
if opts.onChange then opts.onChange(value)end
end
register(id,value,set)
paint()
local function flip()set(not value)end
box.MouseButton1Click:Connect(flip)
lbl.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then flip()end
end)
return set,row
end
U.switch=function(parent,id,label,default,opts)
opts=opts or{}
local row=U.new(__cc20d({35,117,136,234,65},{0x33F25BF0,0xCFDE5C10,0xA35E7765}),{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1},parent)
U.order(row)
local lbl=U.new(__cc20d({132,1,223,188,174,57,228,198,44},{0xCE80AEB5,0xC4689D3C,0x5F51CEAE}),{
Text=label,Font=F.med,TextSize=13,TextColor3=T.text,
BackgroundTransparency=1,Size=UDim2.new(1,-48,1,0),
TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
},row)
local track=U.new(__cc20d({192,5,69,201,75,215,233,219,30,53},{0xA4EE660E,0x98B1B5CD,0xD44B54BF}),{
Size=UDim2.fromOffset(26,14),Position=UDim2.new(1,-26,0.5,-7),
BackgroundColor3=T.field,Text=__cc20d({},{0x40642222,0xBCC93C0A,0xBE766A9F}),AutoButtonColor=false,
},row)
U.corner(track,7)
U.stroke(track,T.line,1,0.4)
local knob=U.new(__cc20d({13,185,95,47,250},{0x6C8E4EA3,0x837CD2D9,0x88116DC8}),{
Size=UDim2.fromOffset(10,10),Position=UDim2.new(0,2,0.5,-5),
BackgroundColor3=T.white,BorderSizePixel=0,
},track)
U.corner(knob,5)
local value=default and true or false
local function paint()
track.BackgroundColor3=value and T.accent or T.field
TweenService:Create(knob,TweenInfo.new(0.12),{Position=UDim2.new(0,value and 14 or 2,0.5,-5)}):Play()
end
local function set(v)
value=v and true or false
Flags[id]=value
paint()
if opts.onChange then opts.onChange(value)end
end
register(id,value,set)
paint()
local function flip()set(not value)end
track.MouseButton1Click:Connect(flip)
lbl.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then flip()end
end)
return set
end
U.slider=function(parent,id,label,min,max,default,opts)
opts=opts or{}
local fmt=opts.format or function(v)return tostring(math.floor(v+0.5))..(opts.unit or __cc20d({},{0xECF951F9,0xFCC3ABA6,0x3A417EE3}))end
local step=opts.step or 1
local row=U.new(__cc20d({40,0,191,165,251},{0x871E369B,0x23EC3575,0x7F6BCCE8}),{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1},parent)
U.order(row)
U.new(__cc20d({17,180,153,161,224,79,189,240,191},{0x35ABF4D4,0x1170CAF7,0xEC21A416}),{
Text=label,Font=F.med,TextSize=13,TextColor3=T.text,
BackgroundTransparency=1,Size=UDim2.new(1,-80,0,16),
TextXAlignment=Enum.TextXAlignment.Left,
},row)
local val=U.new(__cc20d({243,122,81,196,183,179,51,25,126},{0xDF6EF7E6,0x2BEDACFC,0x8F04B6DC}),{
Text=__cc20d({},{0xC7D4DBF3,0x490D2E26,0xC433A064}),Font=F.bold,TextSize=12,TextColor3=T.text,
BackgroundTransparency=1,Position=UDim2.new(1,-100,0,0),
Size=UDim2.new(0,100,0,16),TextXAlignment=Enum.TextXAlignment.Right,
},row)
local hit=U.new(__cc20d({121,222,181,105,82,163,239,30,113,102},{0xAAAD7514,0x4B2717E1,0x1691B90A}),{
Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,22),
BackgroundTransparency=1,Text=__cc20d({},{0xA523186D,0xD0221B49,0x6EFAD275}),AutoButtonColor=false,
},row)
local track=U.new(__cc20d({57,42,207,66,83},{0x376FAA37,0xFC36C492,0xA3EE18A5}),{
Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0.5,-2),
BackgroundColor3=T.field,BorderSizePixel=0,
},hit)
U.corner(track,2)
local fillWrap=U.new(__cc20d({188,26,179,151,89},{0xE0707EA9,0x18542534,0x01DDF83C}),{
Size=UDim2.new(0,0,0,8),Position=UDim2.new(0,0,0.5,-4),
BackgroundColor3=T.accent,BackgroundTransparency=0.82,BorderSizePixel=0,
},hit)
U.corner(fillWrap,4)
local fill=U.new(__cc20d({250,36,89,228,149},{0xBE64F0A6,0x57ABF1C4,0x369A546E}),{
Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0.5,-2),
BackgroundColor3=T.accent,BorderSizePixel=0,
},fillWrap)
U.corner(fill,2)
U.gradient(fill,T.accent,T.accent2,0)
local value=default
local function paint()
local pct=(max==min)and 0 or(value-min)/(max-min)
fillWrap.Size=UDim2.new(pct,0,0,8)
val.Text=fmt(value)
end
local function set(v)
v=math.clamp(tonumber(v)or min,min,max)
v=math.floor(v/step+0.5)*step
value=v
Flags[id]=v
paint()
if opts.onChange then opts.onChange(v)end
end
register(id,value,set)
paint()
local dragging=false
local function fromX(px)
local rel=math.clamp((px-hit.AbsolutePosition.X)/hit.AbsoluteSize.X,0,1)
set(min+rel*(max-min))
end
hit.InputBegan:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=true
fromX(input.Position.X)
end
end)
UIS.InputChanged:Connect(function(input)
if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
fromX(input.Position.X)
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
return set
end
U.dropdown=function(parent,id,label,options,default,opts)
opts=opts or{}
local compact=opts.compact
local wrap=U.new(__cc20d({43,56,38,235,201},{0xADBCA5D6,0x668F9049,0x51C85546}),{
Size=opts.width or UDim2.new(1,0,0,compact and 26 or 46),
BackgroundTransparency=1,
},parent)
U.order(wrap)
if not compact and label then
U.new(__cc20d({250,248,1,204,25,209,123,98,108},{0x6439701B,0xB873E38B,0x3F8E69B2}),{
Text=label,Font=F.reg,TextSize=12,TextColor3=T.sub,
BackgroundTransparency=1,Size=UDim2.new(1,0,0,14),
TextXAlignment=Enum.TextXAlignment.Left,
},wrap)
end
local field=U.new(__cc20d({19,39,215,160,38,62,92,201,45,94},{0x0D13AD05,0xB59F89FD,0x498F13A6}),{
Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,0,compact and 0 or 18),
BackgroundColor3=T.field,Text=__cc20d({},{0x90F8B911,0x3664FB8A,0x40151117}),AutoButtonColor=false,
},wrap)
U.corner(field,5)
U.stroke(field,T.line,1,0.4)
local txt=U.new(__cc20d({161,149,127,69,163,141,60,17,72},{0xBC9C484D,0xD4C593FD,0xF4B59749}),{
Text=default or __cc20d({},{0xEF3D4B02,0xF6026B95,0x21E91545}),Font=F.med,TextSize=13,TextColor3=T.text,
BackgroundTransparency=1,Position=UDim2.new(0,9,0,0),
Size=UDim2.new(1,-28,1,0),
TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
},field)
local ch=U.chevron(field,T.sub,0,0.85)
ch.Position=UDim2.new(1,-14,0.5,0)
local value=default
local function set(v)
if not table.find(options,v)then return end
value=v
txt.Text=v
Flags[id]=v
if opts.onChange then opts.onChange(v)end
end
register(id,value,set)
field.MouseButton1Click:Connect(function()
if activeList and activeField==field then
U.closeDropdown()
return
end
U.openList(field,options,set)
end)
return wrap
end
U.keyfield=function(parent,id,label,default,opts)
opts=opts or{}
local row=U.new(__cc20d({37,31,210,115,102},{0x7FEDA4B7,0x3C5F4E8A,0x9CBAC8B2}),{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1},parent)
U.order(row)
U.new(__cc20d({234,85,140,230,181,18,235,224,21},{0xA4E3E837,0x12491F15,0x74C227C4}),{
Text=label,Font=F.med,TextSize=13,TextColor3=T.text,
BackgroundTransparency=1,Size=UDim2.new(1,-110,1,0),
TextXAlignment=Enum.TextXAlignment.Left,
},row)
local field=U.new(__cc20d({39,14,140,177,231,246,141,242,36,224},{0xD74335AE,0x31994BF2,0x19B74818}),{
Size=UDim2.new(0,100,0,24),Position=UDim2.new(1,-100,0.5,-12),
BackgroundColor3=T.field,Text=__cc20d({},{0x6A5FF042,0x062019E7,0x1FC21E70}),Font=F.med,TextSize=12,
TextColor3=T.text,AutoButtonColor=false,
},row)
U.corner(field,5)
U.stroke(field,T.line,1,0.4)
local value=default
local function render()
field.Text=value and L.bindName(value)or __cc20d({69,206,11,2},{0x55FBCB37,0x819602B5,0x4DD93FBC})
end
local function set(encoded)
value=L.decodeBind(encoded)
Flags[id]=L.encodeBind(value)
render()
if opts.onChange then opts.onChange(value)end
end
register(id,L.encodeBind(default),set)
render()
field.MouseButton1Click:Connect(function()
field.Text=__cc20d({227,199,179},{0xDEF52038,0x753DA336,0x298D5672})
activeCapture=function(input)
if input.KeyCode==Enum.KeyCode.Escape then
render()
return
end
if input.KeyCode==Enum.KeyCode.Backspace then
set(false)
return
end
local b=L.toBind(input)
if b then
set(L.encodeBind(b))
else
render()
end
end
end)
return{get=function()return value end,set=set}
end
U.card=function(parent,title)
local c=U.new(__cc20d({112,55,146,107,88},{0x76A00B32,0x7873352D,0xE83F8867}),{
Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
BackgroundColor3=T.panel,BorderSizePixel=0,
},parent)
U.order(c)
U.corner(c,8)
U.new(__cc20d({58,122,108,200,196,141,235,149,145},{0x37A5858B,0xD5FB5BBB,0x23824C5F}),{
PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,12),
PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),
},c)
U.new(__cc20d({47,135,91,160,201,139,114,11,246,145,157,155},{0x2EC1B0E4,0x3E28D168,0x20CDAC59}),{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},c)
U.new(__cc20d({1,16,159,143,31,95,78,213,17},{0xACDDAACC,0x64A8F4F9,0xA152C409}),{
Text=title,Font=F.bold,TextSize=14,TextColor3=T.text,
BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),
TextXAlignment=Enum.TextXAlignment.Center,
},c)
return c
end
U.textbox=function(parent,default,placeholder)
local f=U.new(__cc20d({45,159,53,144,248,9,121},{0x3220F236,0x7B8B6CD5,0x0C34BD1C}),{
Size=UDim2.new(1,0,0,26),BackgroundColor3=T.field,
Text=default or __cc20d({},{0x9B498998,0xC59E7EF3,0xF13E9689}),Font=F.med,TextSize=13,TextColor3=T.text,
PlaceholderText=placeholder or __cc20d({236,17,30,243},{0x2456D61F,0x68DDC242,0x172ADE1D}),ClearTextOnFocus=false,
TextXAlignment=Enum.TextXAlignment.Left,
},parent)
U.order(f)
U.corner(f,5)
U.stroke(f,T.line,1,0.4)
U.new(__cc20d({167,221,178,248,55,72,137,231,207},{0x9EA8EC38,0x4C63E24E,0x61EBAB6B}),{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},f)
return f
end
U.codebox=function(parent,default,height)
local f=U.new(__cc20d({113,155,32,84,163,40,0},{0x41A168BF,0xE70E64CC,0xA63595A1}),{
Size=UDim2.new(1,0,0,height),BackgroundColor3=T.field,
Text=default or __cc20d({},{0xECBFBB6B,0x2DB162C5,0x16F53EEC}),Font=F.med,TextSize=12,TextColor3=T.text,
PlaceholderText=__cc20d({200,9,216,129,58,54,50,16,187,84,124,146,42,45,32,45,62,97,233,25,124,57,235,102,158,171,42,234,109,104,214},{0x2ADBC0CD,0x36078DB6,0x192E3439}),ClearTextOnFocus=false,
MultiLine=true,TextWrapped=true,
TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
},parent)
U.order(f)
U.corner(f,5)
U.stroke(f,T.line,1,0.4)
U.new(__cc20d({140,94,142,242,55,69,34,209,93},{0x0BB850C1,0x38805285,0xC2EC589F}),{
PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6),
PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),
},f)
return f
end
U.button=function(parent,text,primary,size)
local b=U.new(__cc20d({148,15,226,29,117,82,9,185,188,248},{0xEDEA6FBD,0x1FDF8838,0x26C984CB}),{
Size=size or UDim2.new(1,0,0,26),BackgroundColor3=primary and T.accent or T.field,
Text=text,Font=F.bold,TextSize=12,
TextColor3=primary and T.white or T.text,AutoButtonColor=false,
},parent)
U.corner(b,5)
if not primary then U.stroke(b,T.line,1,0.4)end
b.MouseEnter:Connect(function()
b.BackgroundColor3=primary and Color3.fromRGB(255,140,124)or Color3.fromRGB(45,44,58)
end)
b.MouseLeave:Connect(function()
b.BackgroundColor3=primary and T.accent or T.field
end)
return b
end
U.columns=function(parent)
local host=U.new(__cc20d({173,217,146,128,191},{0x6FD0F7B5,0x93268ED2,0x626C2F48}),{
Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,
},parent)
U.order(host)
local l=U.new(__cc20d({210,100,50,17,144},{0x3A471F3B,0x8DD99C6E,0x5F36A748}),{
Size=UDim2.new(0.5,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,
},host)
U.new(__cc20d({3,184,237,221,66,255,207,186,153,134,134,236},{0xF5E3BE62,0xF72763AE,0xC90C6B80}),{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},l)
local r=U.new(__cc20d({250,139,84,35,118},{0x94FC92B5,0x58B33820,0xD569DC93}),{
Size=UDim2.new(0.5,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,Position=UDim2.new(0.5,6,0,0),
},host)
U.new(__cc20d({46,161,81,107,251,19,165,245,145,119,141,114},{0x1DC0F05C,0xD9EB6D14,0x54BEA56E}),{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},r)
return l,r
end
U.page=function()
local s=U.new(__cc20d({27,252,155,177,49,70,23,68,181,222,44,31,105,198},{0x582082B1,0xC97E9C49,0xA2B2680B}),{
Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
BorderSizePixel=0,ScrollBarThickness=3,
ScrollBarImageColor3=T.accent,ScrollBarImageTransparency=0.4,
CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false,
},contentHost)
local root=U.new(__cc20d({158,109,174,31,65},{0x3C926258,0x48ACF06C,0x26A00AF9}),{
Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y,
BackgroundTransparency=1,Position=UDim2.new(0,4,0,0),
},s)
U.new(__cc20d({167,225,176,185,144,40,203,5,189,249,73,23},{0x608CBFEB,0x86AC2C13,0xFAFA014B}),{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},root)
return s,root
end
U.drawMouse=function(p,c)
local body=U.new(__cc20d({185,125,169,99,120},{0x4AA725FC,0x65D1A89E,0xBE6CA166}),{
Size=UDim2.fromOffset(10,15),Position=UDim2.new(0.5,-5,0.5,-8),
BackgroundTransparency=1,
},p)
U.corner(body,5)
U.stroke(body,c,1.4)
U.new(__cc20d({33,107,2,157,138},{0x1F802B65,0x09E4D89A,0x2B663293}),{
Size=UDim2.fromOffset(1,4),Position=UDim2.new(0.5,-0.5,0,2),
BackgroundColor3=c,BorderSizePixel=0,
},body)
end
U.drawCrosshair=function(p,c)
local ring=U.new(__cc20d({125,172,211,130,252},{0x4C704353,0x60C760F6,0x15B1AFD2}),{
Size=UDim2.fromOffset(13,13),Position=UDim2.new(0.5,-6.5,0.5,-6.5),
BackgroundTransparency=1,
},p)
U.corner(ring,7)
U.stroke(ring,c,1.3)
U.new(__cc20d({246,244,168,250,220},{0x32B81573,0x1AC2AB3A,0x91ADE313}),{
Size=UDim2.fromOffset(2,2),Position=UDim2.new(0.5,-1,0.5,-1),
BackgroundColor3=c,BorderSizePixel=0,
},p)
local ticks={
{UDim2.new(0.5,-0.5,0.5,-11),UDim2.fromOffset(1,3)},
{UDim2.new(0.5,-0.5,0.5,8),UDim2.fromOffset(1,3)},
{UDim2.new(0.5,-11,0.5,-0.5),UDim2.fromOffset(3,1)},
{UDim2.new(0.5,8,0.5,-0.5),UDim2.fromOffset(3,1)},
}
for _,t in ipairs(ticks)do
U.new(__cc20d({3,31,0,38,160},{0xDD9F44C9,0xAF2DFBB2,0x0B61F7AC}),{Position=t[1],Size=t[2],BackgroundColor3=c,BorderSizePixel=0},p)
end
end
U.drawEye=function(p,c)
local e=U.new(__cc20d({219,22,133,223,198},{0xF9CF9699,0xE8CA3919,0x01E742B0}),{
Size=UDim2.fromOffset(15,9),Position=UDim2.new(0.5,-7.5,0.5,-4.5),
BackgroundTransparency=1,
},p)
U.corner(e,5)
U.stroke(e,c,1.3)
local pupil=U.new(__cc20d({165,67,13,193,47},{0x36863B84,0xCB5F2BEC,0x97D93F87}),{
Size=UDim2.fromOffset(4,4),Position=UDim2.new(0.5,-2,0.5,-2),
BackgroundColor3=c,BorderSizePixel=0,
},e)
U.corner(pupil,2)
end
U.drawChevrons=function(p,c)
for i=0,1 do
local ch=U.chevron(p,c,-90,0.9)
ch.Position=UDim2.new(0.5,-3+i*7,0.5,0)
end
end
U.drawTarget=function(p,c)
local ring=U.new(__cc20d({146,117,207,45,2},{0xF058A0CA,0x0A3F8B17,0xDB4C66A5}),{
Size=UDim2.fromOffset(13,13),Position=UDim2.new(0.5,-6.5,0.5,-6.5),
BackgroundTransparency=1,
},p)
U.corner(ring,7)
U.stroke(ring,c,1.3)
local dot=U.new(__cc20d({72,92,82,145,67},{0x887B1CE6,0xADFDBBEE,0x8F736AEA}),{
Size=UDim2.fromOffset(3,3),Position=UDim2.new(0.5,-1.5,0.5,-1.5),
BackgroundColor3=c,BorderSizePixel=0,
},p)
U.corner(dot,2)
end
U.drawGear=function(p,c)
local ring=U.new(__cc20d({220,30,254,137,130},{0x48C4E297,0xF40140CA,0x723E74B7}),{
Size=UDim2.fromOffset(11,11),Position=UDim2.new(0.5,-5.5,0.5,-5.5),
BackgroundTransparency=1,
},p)
U.corner(ring,6)
U.stroke(ring,c,1.3)
local dot=U.new(__cc20d({163,243,190,253,75},{0x0163CAD1,0x1640D879,0x850161F1}),{
Size=UDim2.fromOffset(3,3),Position=UDim2.new(0.5,-1.5,0.5,-1.5),
BackgroundColor3=c,BorderSizePixel=0,
},p)
U.corner(dot,2)
U.new(__cc20d({47,58,93,228,183},{0x5F4CC21E,0xC2035700,0xE7429234}),{Size=UDim2.fromOffset(2,3),Position=UDim2.new(0.5,-1,0.5,-9),BackgroundColor3=c,BorderSizePixel=0},p)
U.new(__cc20d({219,108,151,63,57},{0xE87A6091,0xDCC0B3CB,0x62536674}),{Size=UDim2.fromOffset(2,3),Position=UDim2.new(0.5,-1,0.5,6),BackgroundColor3=c,BorderSizePixel=0},p)
U.new(__cc20d({213,87,232,13,106},{0x09098918,0x39D9B4C3,0x31A5E8D9}),{Size=UDim2.fromOffset(3,2),Position=UDim2.new(0.5,-9,0.5,-1),BackgroundColor3=c,BorderSizePixel=0},p)
U.new(__cc20d({33,0,34,213,25},{0x84D8E478,0x2B97FBE7,0x037D1369}),{Size=UDim2.fromOffset(3,2),Position=UDim2.new(0.5,6,0.5,-1),BackgroundColor3=c,BorderSizePixel=0},p)
end
U.drawSliders=function(p,c)
for i=0,2 do
local y=8+i*6
U.new(__cc20d({255,77,190,23,175},{0xBC8C3F62,0x7FE5F6A4,0x89D5FCA8}),{
Size=UDim2.fromOffset(16,1.4),Position=UDim2.new(0.5,-8,0.5,y-14),
BackgroundColor3=c,BorderSizePixel=0,
},p)
local k=U.new(__cc20d({114,114,74,20,35},{0xE8651A4B,0xDC9AF600,0xF64E39DE}),{
Size=UDim2.fromOffset(4,4),Position=UDim2.new(0.5,-8+(i*5),0.5,y-15.3),
BackgroundColor3=c,BorderSizePixel=0,
},p)
U.corner(k,2)
end
end
local dragging,dragStart,startPos
dragSurface.InputBegan:Connect(function(input)
if unloaded then return end
if input.UserInputType==Enum.UserInputType.MouseButton1 then
dragging=true
dragStart=input.Position
startPos=mainFrame.Position
end
end)
UIS.InputChanged:Connect(function(input)
if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
local d=input.Position-dragStart
mainFrame.Position=UDim2.fromOffset(startPos.X.Offset+d.X,startPos.Y.Offset+d.Y)
end
end)
UIS.InputEnded:Connect(function(input)
if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
U.fit=function()
if unloaded then return end
local cam=workspace.CurrentCamera
local vp=cam and cam.ViewportSize or Vector2.new(1280,720)
local s=math.clamp(math.min((vp.X-40)/W,(vp.Y-60)/H),0.5,1)
uiScale.Scale=s
mainFrame.Position=UDim2.fromOffset(math.floor((vp.X-W*s)/2),math.floor((vp.Y-H*s)/2))
end
U.fit()
if workspace.CurrentCamera then
workspace.CurrentCamera:GetPropertyChangedSignal(__cc20d({35,199,94,247,60,207,73,120,127,39,227,71},{0x7238A5E9,0xC0E60049,0x1FA00ED9})):Connect(U.fit)
end
local mainPage,mainRoot=U.page()
local aimPage,aimRoot=U.page()
local recoilPage,recoilRoot=U.page()
local ragePage,rageRoot=U.page()
local espPage,espRoot=U.page()
local worldPage,worldRoot=U.page()
local luaPage,luaRoot=U.page()
local timingPage,timingRoot=U.page()
local settingsPage,settingsRoot=U.page()
local Tabs={
{draw=U.drawCrosshair,page=mainPage},
{draw=U.drawEye,page=aimPage},
{draw=U.drawChevrons,page=recoilPage},
{draw=U.drawMouse,page=ragePage},
{draw=U.drawTarget,page=espPage},
{draw=U.drawGear,page=worldPage},
{draw=U.drawSliders,page=luaPage},
{draw=U.drawTarget,page=timingPage},
{draw=U.drawGear,page=settingsPage},
}
local paints={}
U.selectTab=function(idx)
for j,tab in ipairs(Tabs)do
tab.page.Visible=(j==idx)
if paints[j]then paints[j](j==idx)end
end
end
U.tabButton=function(draw)
local btn=U.new(__cc20d({210,35,222,194,197,155,229,31,111,196},{0xC7125FD9,0x2D3BDD83,0x4827DAFB}),{
Size=UDim2.fromOffset(28,28),BackgroundTransparency=1,Text=__cc20d({},{0x0E3A2C0C,0x60F97E5E,0x8E79BC09}),
AutoButtonColor=false,ZIndex=5,
},iconHost)
U.order(btn)
local icon=U.new(__cc20d({246,239,121,185,225},{0x970098F9,0x92B9D266,0x32511A64}),{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},btn)
local dot=U.new(__cc20d({121,154,194,62,141},{0x49455956,0x509F1983,0x20DD19C4}),{
Size=UDim2.fromOffset(3,3),Position=UDim2.new(0.5,-1.5,1,-4),
BackgroundColor3=T.white,BackgroundTransparency=0.15,
BorderSizePixel=0,Visible=false,
},btn)
U.corner(dot,2)
local function paint(active)
for _,ch in ipairs(icon:GetChildren())do ch:Destroy()end
draw(icon,active and T.white or Color3.fromRGB(255,222,212))
U.raise(icon,6)
icon.ZIndex=6
dot.ZIndex=6
dot.Visible=active
end
return btn,paint
end
for i,tab in ipairs(Tabs)do
local btn,paint=U.tabButton(tab.draw)
paints[i]=paint
btn.MouseButton1Click:Connect(function()U.selectTab(i)end)
end
window=setmetatable({},{__index=function()return nil end})
window.frame=mainFrame
window.screenGui=gui
function window:isMouseOver()
if not gui.Enabled then return false end
local mouse=UIS:GetMouseLocation()
local function within(obj)
local ap,as=obj.AbsolutePosition,obj.AbsoluteSize
return mouse.X>=ap.X and mouse.X<=ap.X+as.X and mouse.Y>=ap.Y and mouse.Y<=ap.Y+as.Y
end
if within(mainFrame)then return true end
if activeList and within(activeList)then return true end
return false
end
function window:toggle()gui.Enabled=not gui.Enabled end
function window:destroy()
unloaded=true
pcall(function()gui:Destroy()end)
end
function window:handleCapture(input)
if not activeCapture then return false end
local cap=activeCapture
activeCapture=nil
cap(input)
return true
end
U.selectTab(1)
L.ensureConfigDir=function()
if type(isfolder)==__cc20d({185,103,175,202,168,46,57,102},{0x711B8FAB,0xE30418E4,0x312DB14C})and type(makefolder)==__cc20d({147,232,110,35,202,252,186,74},{0x961722C5,0x9C64598C,0x16647385})then
local ok,exists=pcall(isfolder,CONFIG_DIR)
if ok and not exists then pcall(makefolder,CONFIG_DIR)end
end
end
L.sanitizeName=function(name)
local cleaned=tostring(name or __cc20d({},{0xEF70BDE1,0x62CAF9E0,0x65B14E5F})):gsub(__cc20d({247,247,21,109,1,55,6,159,15},{0x87CF7CD8,0x740D6DB4,0x1ED8ABAB}),__cc20d({},{0xA0060C67,0x0694017A,0x3F2E549E}))
cleaned=cleaned:match(__cc20d({138,245,44,126,27,167,60,146,86,178,201,182},{0x86E2623D,0x43045F51,0x1CAAD952}))
return cleaned:sub(1,CONFIG_NAME_LENGTH)
end
L.saveConfig=function(name)
if type(writefile)~=__cc20d({251,196,225,232,187,158,228,198},{0xF6FB6898,0x82FA066E,0xA60DC249})then return false,__cc20d({192,56,213,174,132,179,248,252,22,25,106,120,48,113,220,41,19},{0xC0E59009,0x90C2E901,0x918BAB59})end
L.ensureConfigDir()
local ok,data=pcall(function()return HttpService:JSONEncode(Flags)end)
if not ok then return false,__cc20d({121,81,168,193,210,242,117,87,132,177,251,13,233},{0x167BADC5,0xD6521E2A,0xF582D3CA})end
local wok=pcall(writefile,CONFIG_DIR..__cc20d({142},{0xFFAD7BA7,0xE93F7947,0x5ED42150})..name..__cc20d({255,0,107,142,36},{0xE75B2846,0x2BC0FE5D,0xAC0AD87F}),data)
return wok,wok and __cc20d({170,31,173,58,59,23},{0x16277815,0xAA0BEDE4,0xB101D083})..name or __cc20d({20,51,2,252,48,227,225,177,203,35,221,131},{0x4F1BD5A2,0x620A2A41,0xD4D6FD9C})
end
L.loadConfigFile=function(name)
if type(readfile)~=__cc20d({179,137,151,62,203,128,57,32},{0x6DE9A03C,0x7BE83C71,0xE2ED4C92})then return false,__cc20d({4,59,222,48,169,224,147,58,59,109,128,144,18,193,130,185,16},{0xA4FD2067,0xFFB53EC1,0x03088C0A})end
local path=CONFIG_DIR..__cc20d({67},{0x35C237B5,0x28122A52,0x6CE24E19})..name..__cc20d({38,169,13,202,250},{0xE668CCBD,0x15E97F22,0xE991B90D})
if type(isfile)==__cc20d({64,210,235,171,156,133,239,7},{0x786114E1,0x54D354F7,0xFD89E24F})then
local ok,exists=pcall(isfile,path)
if ok and not exists then return false,__cc20d({206,238,164,44,88,34,68,100,40},{0x61DDA3C2,0xDBCF44F6,0xC4DEF7E4})end
end
local ok,data=pcall(readfile,path)
if not ok or type(data)~=__cc20d({134,50,215,219,111,138},{0xE32DEC20,0xE7E4D5A0,0x6CC5376C})then return false,__cc20d({217,85,40,219,149,165,141,74,154,183,33},{0xD94C4EBD,0xD2BCCBDA,0x5E49D938})end
local dok,decoded=pcall(function()return HttpService:JSONDecode(data)end)
if not dok or type(decoded)~=__cc20d({218,109,203,98,101},{0x51C86D3F,0x806213CB,0xB91ED536})then return false,__cc20d({230,63,235,153,18,42,76,227},{0x30D4EF5E,0x8F248DFB,0xFB087B82})end
for id,def in pairs(Defaults)do
if decoded[id]==nil then pcall(Setters[id],def)end
end
for id,v in pairs(decoded)do
local setter=Setters[id]
if setter then pcall(setter,v)end
end
L.stopHold()
held=false
aimHeld=false
assistTarget=nil
return true,__cc20d({244,254,84,113,197,89,161},{0x69587478,0xDDFF88DE,0xAB801D39})..name
end
L.deleteConfigFile=function(name)
if type(delfile)~=__cc20d({125,21,165,79,245,19,117,129},{0xF6689F21,0xD09D1738,0x472D33F2})then return false,__cc20d({24,67,134,73,194,105,255,136,79,91,38,66,32,230,95,34,107},{0x39B16F48,0x1E7EB19D,0x26FDD888})end
local ok=pcall(delfile,CONFIG_DIR..__cc20d({208},{0x91CA7044,0xBB6E7B37,0xF5EEA324})..name..__cc20d({181,205,250,40,53},{0x06BF316B,0x8AD4F238,0x5925B33B}))
return ok,ok and __cc20d({123,18,189,38,230,16,185,215},{0xDC05009E,0xDEA871C5,0x95B7B295})..name or __cc20d({170,94,146,148,112,26,190,109,163,237,224,233,125},{0x9B0651B7,0xE4F197C8,0x628AA914})
end
local VIRTUAL_KEYS={
Space=0x20,Return=0x0D,Tab=0x09,Backspace=0x08,Escape=0x1B,
LeftShift=0xA0,RightShift=0xA1,LeftControl=0xA2,RightControl=0xA3,
LeftAlt=0xA4,RightAlt=0xA5,
Left=0x25,Up=0x26,Right=0x27,Down=0x28,
Zero=0x30,One=0x31,Two=0x32,Three=0x33,Four=0x34,
Five=0x35,Six=0x36,Seven=0x37,Eight=0x38,Nine=0x39,
}
for index=1,12 do VIRTUAL_KEYS[__cc20d({172},{0xB3B25EA3,0x63E556DE,0xA5AC5C21})..index]=0x6F+index end
L.toVirtualKey=function(code)
local name=code.Name
if VIRTUAL_KEYS[name]then return VIRTUAL_KEYS[name]end
if#name==1 then return string.byte(name:upper())end
return nil
end
L.isMouseBind=function(bind)return bind~=nil and bind.kind==__cc20d({54,49,129,20,100,187,63,109,63,105,197,89,21},{0xAF7733C2,0xE1442CBF,0xDFDF8C57})end
L.pressOutput=function(bind)
if bind and bind.kind==__cc20d({205,47,196,28,191,217,93},{0xAF77F5EC,0x87A64EF6,0x074CF088})then
keypress(L.toVirtualKey(bind.code)or bind.code)
elseif bind and bind.code==Enum.UserInputType.MouseButton2 then
mouse2press()
else
mouse1press()
end
end
L.releaseOutput=function(bind)
if bind and bind.kind==__cc20d({66,79,173,252,133,5,249},{0x8E3D3F93,0x33AF2794,0xE15F2895})then
keyrelease(L.toVirtualKey(bind.code)or bind.code)
elseif bind and bind.code==Enum.UserInputType.MouseButton2 then
mouse2release()
else
mouse1release()
end
end
L.getAimPoint=function()
if Config.aimAt==__cc20d({62,48,6,120,243,162},{0xDA633D37,0x2A9A666A,0xC9896367})then return currentCamera.ViewportSize/2 end
return userInputService:GetMouseLocation()
end
L.readTeamValue=function(player)
local character=player.Character
local stats=player:FindFirstChild(__cc20d({214,249,202,232,205,27,238,204,221,174,12},{0x6C8C2119,0xBD46AED8,0xAB73F369}))
for _,name in ipairs(TEAM_KEYS)do
local value=player:GetAttribute(name)
if value==nil and character then value=character:GetAttribute(name)end
if value==nil then
local object=player:FindFirstChild(name)or(stats and stats:FindFirstChild(name))
if object and object:IsA(__cc20d({208,168,148,41,209,73,118,221,77},{0x88BF9E98,0x9502A67B,0xE1514EE3}))then value=object.Value end
end
if value~=nil then return value end
end
return nil
end
L.isTeammate=function(player)
if manualTeammates[player.UserId]then return true end
if player.Team~=nil and localPlayer.Team~=nil then return player.Team==localPlayer.Team end
if not Config.smartTeam then return false end
local mine=L.readTeamValue(localPlayer)
return mine~=nil and L.readTeamValue(player)==mine
end
L.toggleManualTeammate=function()
local point=L.getAimPoint()
local closest,closestDistance=nil,200
for _,player in ipairs(playersService:GetPlayers())do
if player==localPlayer then continue end
local character=player.Character
local root=character and character:FindFirstChild(__cc20d({21,135,78,154,114,219,40,149,155,252,242,110,131,205,66,110},{0x2AA310B9,0x8215B03F,0x1DADC423}))
if not root then continue end
local screen,onScreen=currentCamera:WorldToViewportPoint(root.Position)
if not onScreen then continue end
local distance=(Vector2.new(screen.X,screen.Y)-point).Magnitude
if distance<closestDistance then closest,closestDistance=player,distance end
end
if not closest then
warn(__cc20d({196,140,90,143,62,177,154,178,134,236,111,94,93,162,233,102,3,173,119,235,169,141,71,20,183,184,218,35,12},{0x9373F527,0xA6B7C6AF,0x2A114BCE}))
return
end
local marked=not manualTeammates[closest.UserId]
manualTeammates[closest.UserId]=marked or nil
print(closest.Name..(marked and __cc20d({103,23,215,53,100,76,247,102,194,67,100,47,22,237,64,105,19,100,252},{0x89B733B3,0xE5D20DAA,0xBEBD8709})or __cc20d({53,84,73,95,229,28,118,187,10},{0xB22996F3,0x2CADF07F,0xAD720590})))
end
L.printTeamInfo=function()
for _,player in ipairs(playersService:GetPlayers())do
print(string.format(__cc20d({1,57,110,114,72,167,54,10,89,58,23,150,126,239,121,24,72,32,1,23,64,168,29,52,244,48,229,56,214},{0x5838A3E5,0xB7724CE5,0x71256832}),player.Name,tostring(player.Team),tostring(player.TeamColor)))
for key,value in pairs(player:GetAttributes())do print(__cc20d({223,106,30,6,219,146,48,251,16,130,8,98,123},{0xCEDF106A,0x9E96E94E,0x227D9CAE}),key,value)end
if player.Character then
for key,value in pairs(player.Character:GetAttributes())do print(__cc20d({110,0,105,55,161,47,45,124,166,38,28,179,73,156,250,157},{0xA6A9AC27,0x12EB4CB5,0x479A76EA}),key,value)end
end
for _,child in ipairs(player:GetChildren())do
if child:IsA(__cc20d({76,199,189,149,88,98,25,4,153},{0xFC8B6FA3,0x481438AD,0x6329C921}))then print(__cc20d({76,81,154,27,200,96,233},{0x68C816F2,0xD30DACFF,0x335A0C56}),child.Name,child.Value)end
end
local stats=player:FindFirstChild(__cc20d({135,126,201,206,135,241,203,30,100,26,81},{0x38F90F91,0x8EDA13F7,0xC1B86713}))
if stats then
for _,child in ipairs(stats:GetChildren())do
if child:IsA(__cc20d({153,51,3,216,156,33,225,189,42},{0xF22D8DC7,0xAE638572,0xD3BB69DC}))then print(__cc20d({45,4,26,158,39,253,12,212,141,7,25,28},{0x0040AD85,0xCB233EF9,0x2E53FAE5}),child.Name,child.Value)end
end
end
end
end
L.getEnemyCharacters=function()
local characters={}
for _,player in ipairs(playersService:GetPlayers())do
if player~=localPlayer and player.Character then table.insert(characters,player.Character)end
end
return characters
end
L.castAimRay=function(origin,direction)
local character=localPlayer.Character
if not character then return nil end
if not Config.wallCheck then
rayParams.FilterType=Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances=L.getEnemyCharacters()
return workspace:Raycast(origin,direction,rayParams)
end
rayParams.FilterType=Enum.RaycastFilterType.Exclude
local ignore={character}
local result=nil
for _=1,MAX_WALL_STEPS do
rayParams.FilterDescendantsInstances=ignore
result=workspace:Raycast(origin,direction,rayParams)
if not result then return nil end
local part=result.Instance
local model=part:FindFirstAncestorOfClass(__cc20d({204,138,23,55,31},{0x3BCB301F,0x5FDA52EB,0x8FA3CCFA}))
local isPlayerPart=model~=nil and playersService:GetPlayerFromCharacter(model)~=nil
if isPlayerPart or part.Transparency<SEE_THROUGH_TRANSPARENCY then return result end
table.insert(ignore,part)
end
return nil
end
L.getTargetPlayer=function()
if not localPlayer.Character then return nil end
local point=L.getAimPoint()
local ray=currentCamera:ViewportPointToRay(point.X,point.Y)
local result=L.castAimRay(ray.Origin,ray.Direction*Config.maxDistance)
if not result then return nil end
local model=result.Instance:FindFirstAncestorOfClass(__cc20d({194,48,184,192,119},{0xDBAFEFD3,0x619C0598,0x3664A46D}))
if not model then return nil end
local player=playersService:GetPlayerFromCharacter(model)
if not player or player==localPlayer then return nil end
local humanoid=model:FindFirstChildOfClass(__cc20d({183,76,190,148,42,234,159,7},{0xB8F3C2F1,0x096AA53B,0xE134AE99}))
if not humanoid or humanoid.Health<=0 then return nil end
if Config.teamCheck and L.isTeammate(player)then return nil end
return player
end
L.isActive=function()
if Config.mode==__cc20d({197,2,164,186,185,35},{0xE1F23638,0x5BE00B79,0x04EEB205})then return true end
if Config.mode==__cc20d({60,81,150,247},{0x185C067F,0x1426F3B9,0x0840CEE9})then return held end
return toggled
end
L.fire=function()
local bind=Config.fireBind
ignoreInputUntil=os.clock()+0.15+KEY_HOLD_TIME
if L.isMouseBind(bind)then botShotUntil=os.clock()+0.15 end
if bind and bind.kind==__cc20d({60,209,76,164,197,227,141},{0x039CFC9B,0xAD8EEBAD,0xA672C6F6})then
local virtualKey=L.toVirtualKey(bind.code)
local keyArgument=virtualKey or bind.code
keypress(keyArgument)
task.wait(KEY_HOLD_TIME)
keyrelease(keyArgument)
elseif bind and bind.code==Enum.UserInputType.MouseButton2 then
mouse2click()
else
mouse1click()
end
end
L.startHold=function()
if holding then return end
holdBind=Config.fireBind
holding=true
ignoreInputUntil=os.clock()+0.3
L.pressOutput(holdBind)
end
L.stopHold=function()
if not holding then return end
holding=false
ignoreInputUntil=os.clock()+0.3
L.releaseOutput(holdBind)
holdBind=nil
lastClick=os.clock()
end
L.getAimPart=function(character)
local root=character:FindFirstChild(__cc20d({157,84,216,87,6,222,153,194,75,29,2,82,67,11,26,109},{0x49CEFACF,0x46356CD3,0xE070F3D7}))
if Config.aimPart==__cc20d({207,27,242,189},{0x5217C1EC,0x0F8147DB,0x9549296A})then return character:FindFirstChild(__cc20d({127,0,60,122},{0x727A9593,0xB4F16CC0,0x7D2891E6}))or root end
return character:FindFirstChild(__cc20d({174,127,44,2,143,24,209,43,173,147},{0x4A22A638,0xEDF85D74,0x12277E5E}))or character:FindFirstChild(__cc20d({53,145,81,51,61},{0xFD97FF59,0x7C69DDE5,0x2A5E70D4}))or root
end
L.isPartVisible=function(part,character)
local origin=currentCamera.CFrame.Position
local direction=part.Position-origin
local ignore={localPlayer.Character}
rayParams.FilterType=Enum.RaycastFilterType.Exclude
for _=1,MAX_WALL_STEPS do
rayParams.FilterDescendantsInstances=ignore
local result=workspace:Raycast(origin,direction,rayParams)
if not result then return true end
local hit=result.Instance
if hit:IsDescendantOf(character)then return true end
if hit.Transparency<SEE_THROUGH_TRANSPARENCY then return false end
table.insert(ignore,hit)
end
return false
end
L.getAimTarget=function()
if not localPlayer.Character then return nil end
local point=L.getAimPoint()
local cameraPosition=currentCamera.CFrame.Position
local closestPart,closestDistance=nil,Config.aimFov
for _,player in ipairs(playersService:GetPlayers())do
if player==localPlayer then continue end
if Config.teamCheck and L.isTeammate(player)then continue end
local character=player.Character
local humanoid=character and character:FindFirstChildOfClass(__cc20d({130,33,12,240,133,206,139,116},{0xD67E3D2A,0x976C7060,0xEDB478C6}))
if not humanoid or humanoid.Health<=0 then continue end
local part=L.getAimPart(character)
if not part then continue end
if(part.Position-cameraPosition).Magnitude>Config.aimDistance then continue end
local screen,onScreen=currentCamera:WorldToViewportPoint(part.Position)
if not onScreen then continue end
local distance=(Vector2.new(screen.X,screen.Y)-point).Magnitude
if distance>=closestDistance then continue end
if Config.aimVisibleCheck and not L.isPartVisible(part,character)then continue end
closestPart,closestDistance=part,distance
end
return closestPart
end
L.updateAim=function()
if not Config.aimEnabled or rageEngaged then return end
if Config.aimBind and not aimHeld then return end
if not isrbxactive()then return end
if window and window:isMouseOver()then return end
local part=L.getAimTarget()
if not part then return end
local screen=currentCamera:WorldToViewportPoint(part.Position)
local delta=Vector2.new(screen.X,screen.Y)-L.getAimPoint()
if delta.Magnitude<AIM_DEADZONE then return end
local step=delta/Config.aimSmoothing
mousemoverel(math.round(step.X),math.round(step.Y))
end
L.getAssistPart=function(player,radius)
local character=player.Character
local humanoid=character and character:FindFirstChildOfClass(__cc20d({239,242,253,187,12,33,33,24},{0xDAAD1D19,0x49FC734F,0xA0FF3B35}))
if not humanoid or humanoid.Health<=0 then return nil end
if Config.assistTeamCheck and L.isTeammate(player)then return nil end
local part=L.getAimPart(character)
if not part then return nil end
if(part.Position-currentCamera.CFrame.Position).Magnitude>Config.assistDistance then return nil end
local screen,onScreen=currentCamera:WorldToViewportPoint(part.Position)
if not onScreen then return nil end
local distance=(Vector2.new(screen.X,screen.Y)-L.getAimPoint()).Magnitude
if distance>radius then return nil end
if Config.assistVisibleCheck and not L.isPartVisible(part,character)then return nil end
return part,distance
end
L.releaseAssist=function()
assistTarget=nil
assistRemainder=Vector2.zero
assistReleasedUntil=os.clock()+ASSIST_REACQUIRE_DELAY
end
L.updateAssist=function()
if not Config.assistEnabled or rageEngaged or not localPlayer.Character or not isrbxactive()then
assistTarget=nil
return
end
if Config.aimEnabled and(not Config.aimBind or aimHeld)then
assistTarget=nil
return
end
if window and window:isMouseOver()then
assistTarget=nil
return
end
local part,distance
if assistTarget then
part,distance=L.getAssistPart(assistTarget,Config.assistBreakRadius)
if not part then
L.releaseAssist()
return
end
end
if not assistTarget then
if os.clock()<assistReleasedUntil then return end
local best=Config.assistRadius
for _,player in ipairs(playersService:GetPlayers())do
if player==localPlayer then continue end
local candidate,candidateDistance=L.getAssistPart(player,best)
if candidate and candidateDistance<best then
assistTarget,part,distance,best=player,candidate,candidateDistance,candidateDistance
end
end
if not assistTarget then return end
end
local screen=currentCamera:WorldToViewportPoint(part.Position)
local delta=Vector2.new(screen.X,screen.Y)-L.getAimPoint()
if delta.Magnitude<AIM_DEADZONE then return end
local falloff=1-math.clamp(distance/Config.assistBreakRadius,0,1)*0.5
local move=delta*(Config.assistStrength/100)*falloff+assistRemainder
local moveX,moveY=math.round(move.X),math.round(move.Y)
assistRemainder=move-Vector2.new(moveX,moveY)
if moveX~=0 or moveY~=0 then mousemoverel(moveX,moveY)end
end
L.updateFov=function()
if fovCircle then
local visible=Config.aimEnabled and Config.aimShowFov
fovCircle.Visible=visible
if visible then
fovCircle.Position=L.getAimPoint()
fovCircle.Radius=Config.aimFov
end
end
if assistCircle then
assistCircle.Visible=Config.assistEnabled and Config.assistShowRadius
if assistCircle.Visible then
assistCircle.Position=L.getAimPoint()
assistCircle.Radius=Config.assistRadius
end
end
end
L.isShooting=function()
if Config.recoilManual and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)then return true end
if Config.recoilBot then
if holding and L.isMouseBind(holdBind)then return true end
if os.clock()<botShotUntil then return true end
end
return false
end
L.updateRecoil=function(deltaTime)
if not Config.recoilEnabled or not isrbxactive()then
recoilStart=nil
recoilRemainder=Vector2.zero
return
end
if window and window:isMouseOver()then
recoilStart=nil
return
end
if not L.isShooting()then
recoilStart=nil
recoilRemainder=Vector2.zero
return
end
local now=os.clock()
recoilStart=recoilStart or now
local ramp=1
if Config.recoilRamp>0 then
ramp=math.clamp((now-recoilStart)*1000/Config.recoilRamp,0,1)
end
local move=Vector2.new(Config.recoilX,Config.recoilY)*(deltaTime*60)*ramp+recoilRemainder
local moveX,moveY=math.round(move.X),math.round(move.Y)
recoilRemainder=move-Vector2.new(moveX,moveY)
if moveX~=0 or moveY~=0 then mousemoverel(moveX,moveY)end
end
L.isFiringNow=function()
if userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)then return true end
return holding or os.clock()<botShotUntil
end
L.angleDelta=function(from,to)return((to-from+540)%360)-180 end
L.getFreestandOffset=function(root,real)
local closest,closestDistance=nil,math.huge
for _,player in ipairs(playersService:GetPlayers())do
if player==localPlayer or L.isTeammate(player)then continue end
local character=player.Character
local enemyRoot=character and character:FindFirstChild(__cc20d({64,245,52,90,79,216,74,246,11,175,242,115,121,112,169,238},{0xF67F6B7B,0xA942AEC1,0xE9FB702C}))
local humanoid=character and character:FindFirstChildOfClass(__cc20d({96,243,225,42,194,187,26,38},{0x0AFD6CFC,0x656D1F30,0xFB6DD259}))
if not(enemyRoot and humanoid)or humanoid.Health<=0 then continue end
local distance=(enemyRoot.Position-root.Position).Magnitude
if distance<closestDistance then closest,closestDistance=enemyRoot,distance end
end
if not closest then return 0 end
local toEnemy=closest.Position-root.Position
local bearing=math.deg(math.atan2(toEnemy.X,toEnemy.Z))
local _,realYaw=real:ToOrientation()
return L.angleDelta(math.deg(realYaw),bearing+90)
end
L.restoreSpin=function()
if spinRoot and spinReal and spinRoot.Parent then spinRoot.CFrame=spinReal end
spinRoot=nil
spinReal=nil
end
L.applySpin=function(deltaTime)
L.restoreSpin()
spinApplied=false
if not Config.spinEnabled then return end
local character=localPlayer.Character
local root=character and character:FindFirstChild(__cc20d({169,3,224,14,106,41,176,95,147,180,233,180,42,246,12,110},{0xEEE5D997,0xD6793CDB,0xB2EFD860}))
local humanoid=character and character:FindFirstChildOfClass(__cc20d({57,106,124,2,231,58,204,239},{0x49E1DE4E,0xF5A8BD43,0xDBC1F815}))
if not(root and humanoid)or humanoid.Health<=0 or humanoid.Sit then return end
if Config.spinPauseOnShoot and L.isFiringNow()then return end
local real=root.CFrame
if Config.spinMode==__cc20d({210,130,117,43},{0xBF7F78A5,0xFC6C194C,0x077C3D2F})then
spinAngle=(spinAngle+Config.spinSpeed*deltaTime)%360
elseif Config.spinMode==__cc20d({155,56,109,68,148,83},{0x23459FA5,0x332BA5AF,0x7940F953})then
spinAngle=math.random(-Config.spinJitter,Config.spinJitter)
elseif Config.spinMode==__cc20d({94,23,32,214,2,26,85,155,7},{0xBF3DA082,0xE29F4E8F,0xD1FAA82A})then
spinAngle=180
else
local target
if Config.spinAutoDirection then
target=L.getFreestandOffset(root,real)
elseif Config.spinMode==__cc20d({153,99,27,10,75,83},{0x32040294,0x5A367798,0x247259CE})then
local now=os.clock()
if now>=spinRandomUntil then
spinTargetAngle=math.random(-Config.spinJitter,Config.spinJitter)
spinRandomUntil=now+Config.spinRandomInterval/1000
end
target=spinTargetAngle
else
target=Config.spinStaticAngle
end
if Config.spinSmoothing>0 then
local rate=math.clamp(deltaTime*1000/Config.spinSmoothing,0,1)
spinAngle+=L.angleDelta(spinAngle,target)*rate
else
spinAngle=target
end
spinAngle=L.angleDelta(0,spinAngle)
end
spinRoot=root
spinReal=real
spinApplied=true
spinOffset=CFrame.Angles(0,math.rad(spinAngle),0)
*CFrame.Angles(math.rad(Config.spinLeanPitch),0,math.rad(Config.spinLeanRoll))
root.CFrame=spinReal*spinOffset
end
L.spawnBulletTracer=function(originWorld,hitWorld)
if not Config.rageBulletTracer then return end
local originScreen=currentCamera:WorldToViewportPoint(originWorld)
local hitScreen=currentCamera:WorldToViewportPoint(hitWorld)
if originScreen.Z<=0 and hitScreen.Z<=0 then return end
local line=Drawing.new(__cc20d({87,113,62,163},{0x0F92EAD4,0xBDD1DB6F,0x61FCA673}))
line.Thickness=2
line.Transparency=1
line.ZIndex=5
line.Color=Color3.fromRGB(Config.chamsRed,Config.chamsGreen,Config.chamsBlue)
line.From=Vector2.new(originScreen.X,originScreen.Y)
line.To=Vector2.new(hitScreen.X,hitScreen.Y)
line.Visible=true
table.insert(bulletTracers,{line=line,expire=os.clock()+BULLET_TRACER_LIFETIME})
end
L.updateBulletTracers=function()
for index=#bulletTracers,1,-1 do
local entry=bulletTracers[index]
if os.clock()>=entry.expire then
pcall(function()entry.line:Remove()end)
table.remove(bulletTracers,index)
end
end
end
L.clearBulletTracers=function()
for _,entry in ipairs(bulletTracers)do
pcall(function()entry.line:Remove()end)
end
table.clear(bulletTracers)
end
L.getRagePart=function(character)
local root=character:FindFirstChild(__cc20d({118,208,236,45,239,218,93,229,29,16,35,62,159,42,52,191},{0x01085B40,0x2E87368A,0x01EEF2B5}))
if Config.ragePart==__cc20d({140,125,102,147},{0xE0011615,0xD9CA5A73,0xC450A15E})then return character:FindFirstChild(__cc20d({73,215,33,118},{0x8215BF71,0x0D772574,0x39030C26}))or root end
return character:FindFirstChild(__cc20d({223,29,65,134,135,154,81,122,216,236},{0x301662A7,0x67962EA8,0x0E8915F7}))or character:FindFirstChild(__cc20d({97,150,32,69,69},{0x899098F9,0x50BB18EA,0x2400BEA3}))or root
end
L.getRageTarget=function()
local cameraPosition=currentCamera.CFrame.Position
local closestPart,closestDistance=nil,Config.rageDistance
for _,player in ipairs(playersService:GetPlayers())do
if player==localPlayer then continue end
if Config.rageTeamCheck and L.isTeammate(player)then continue end
local character=player.Character
local humanoid=character and character:FindFirstChildOfClass(__cc20d({182,3,246,231,38,195,97,167},{0xDF816260,0xB8DAADD0,0x13EEAD96}))
if not humanoid or humanoid.Health<=0 then continue end
local part=L.getRagePart(character)
if not part then continue end
local distance=(part.Position-cameraPosition).Magnitude
if distance>=closestDistance then continue end
if Config.rageMode==__cc20d({31,146,226,143},{0x9A583DBE,0x164122BC,0x1A2CDF50})then
local _,onScreen=currentCamera:WorldToViewportPoint(part.Position)
if not onScreen then continue end
end
local wallbang=Config.rageWallbang and Config.rageMode==__cc20d({133,5,144,93,150,16},{0xAEFF60C3,0x8A4E3280,0xA041F8EA})
if Config.rageWallCheck and not wallbang and not L.isPartVisible(part,character)then continue end
closestPart,closestDistance=part,distance
end
return closestPart
end
L.ensureSilentHook=function()
if shared.TriggerBotHooked or silentHookFailed then return end
local installed,hookError=pcall(function()
local oldNamecall
oldNamecall=hookmetamethod(game,__cc20d({28,140,184,72,59,54,63,92,24,236},{0x68AC09D3,0xBB0A1C67,0x235D75B5}),newcclosure(function(self,...)
local method=getnamecallmethod()
local handler=shared.TriggerBotNamecall
if handler then return handler(oldNamecall,method,self,...)end
return oldNamecall(self,...)
end))
end)
if installed then
shared.TriggerBotHooked=true
else
silentHookFailed=true
warn(__cc20d({83,197,109,216,59,246,183,138,62,50,2,152,223,190,63,162,25,255,165,196,246,211,144,67},{0xB4AC8C24,0xBFAA3B88,0x6C0B4543})..tostring(hookError))
end
end
L.updateRage=function()
rageTarget=nil
rageEngaged=false
silentTarget=nil
local character=localPlayer.Character
local humanoid=character and character:FindFirstChildOfClass(__cc20d({209,192,24,179,209,115,1,247},{0x605DAE12,0xDD5EBB47,0xF15B1435}))
if not Config.rageEnabled or not humanoid or humanoid.Health<=0 or not isrbxactive()then
rageRemainder=Vector2.zero
return
end
if window and window:isMouseOver()then return end
local part=L.getRageTarget()
if not part then
rageRemainder=Vector2.zero
return
end
rageTarget=part
local now=os.clock()
local ready=(now-lastRageShot)*1000>=Config.rageDelay
if Config.rageMode==__cc20d({31,93,225,29,247,253},{0x1B4A3C52,0xD77CEB32,0xB60A45CB})then
L.ensureSilentHook()
silentTarget=part
if ready then
lastRageShot=now
silentUntil=now+SILENT_WINDOW
task.spawn(L.fire)
end
return
end
rageEngaged=true
local screen=currentCamera:WorldToViewportPoint(part.Position)
local delta=Vector2.new(screen.X,screen.Y)-L.getAimPoint()
if delta.Magnitude>Config.rageTolerance then
local move=delta*(Config.rageSnap/100)+rageRemainder
local moveX,moveY=math.round(move.X),math.round(move.Y)
rageRemainder=move-Vector2.new(moveX,moveY)
if moveX~=0 or moveY~=0 then mousemoverel(moveX,moveY)end
return
end
if ready then
lastRageShot=now
L.spawnBulletTracer(currentCamera.CFrame.Position,part.Position)
task.spawn(L.fire)
end
end
L.onNamecall=function(oldNamecall,method,self,...)
if method~=__cc20d({119,21,0,128,102,174,240},{0xF83FE0D5,0xC493DB6F,0x300BC74A})or not silentTarget or os.clock()>silentUntil or self~=workspace then
return oldNamecall(self,...)
end
if checkcaller()then return oldNamecall(self,...)end
local origin,direction,params=...
if typeof(origin)~=__cc20d({93,174,44,81,189,99,242},{0x33F53E4B,0x99A4AF6A,0xB55282C9})or typeof(direction)~=__cc20d({39,86,183,71,230,124,79},{0xFA2623F1,0x164F520D,0x2927A9FF})then
return oldNamecall(self,...)
end
local range=direction.Magnitude
if range<SILENT_MIN_RANGE then return oldNamecall(self,...)end
local unit=direction.Unit
local look=currentCamera.CFrame.LookVector
local dot=unit.X*look.X+unit.Y*look.Y+unit.Z*look.Z
if dot<SILENT_MIN_DOT then return oldNamecall(self,...)end
local targetPosition=silentTarget.Position
local redirected=(targetPosition-origin).Unit*range
L.spawnBulletTracer(origin,targetPosition)
if Config.rageWallbang then
local character=silentTarget:FindFirstAncestorOfClass(__cc20d({212,204,41,47,67},{0x704F10EB,0x9B826FA2,0x394529EF}))
if character then
wallbangParams.FilterDescendantsInstances={character}
if typeof(params)==__cc20d({145,101,194,55,251,127,125,139,26,35,133,201,2},{0x31933A72,0xDFFAE9E8,0xBA4C206F})then
wallbangParams.IgnoreWater=params.IgnoreWater
wallbangParams.CollisionGroup=params.CollisionGroup
wallbangParams.RespectCanCollide=params.RespectCanCollide
end
params=wallbangParams
end
end
setnamecallmethod(method)
if params~=nil then return oldNamecall(self,origin,redirected,params)end
return oldNamecall(self,origin,redirected)
end
L.restoreBody=function()
for part,saved in pairs(bodySaved)do
pcall(function()
part.LocalTransparencyModifier=saved.modifier
part.Transparency=saved.transparency
end)
end
table.clear(bodySaved)
end
L.restoreCamera=function()
if cameraObject and cameraReal then cameraObject.CFrame=cameraReal end
cameraObject=nil
cameraReal=nil
if viewRoot and viewReal and viewRoot.Parent then viewRoot.CFrame=viewReal end
viewRoot=nil
viewReal=nil
L.restoreBody()
end
L.revealBody=function(character)
for _,descendant in ipairs(character:GetDescendants())do
if not descendant:IsA(__cc20d({8,134,173,119,189,201,90,132},{0x2A3909F0,0xD9D003BB,0xD99E1D40}))or not BODY_PART_NAMES[descendant.Name]then continue end
bodySaved[descendant]={modifier=descendant.LocalTransparencyModifier,transparency=descendant.Transparency}
descendant.LocalTransparencyModifier=0
if descendant.Transparency>SEE_THROUGH_TRANSPARENCY then descendant.Transparency=0 end
end
end
L.applyCamera=function()
L.restoreCamera()
local character=localPlayer.Character
if not Config.thirdPersonEnabled or not character then return end
local camera=workspace.CurrentCamera
if not camera then return end
local real=camera.CFrame
local distance=Config.thirdPersonDistance
cameraRayParams.FilterDescendantsInstances={character}
local result=workspace:Raycast(real.Position,-real.LookVector*(distance+0.5),cameraRayParams)
if result then distance=math.max(result.Distance-0.5,0)end
cameraObject=camera
cameraReal=real
camera.CFrame=real*CFrame.new(0,0,distance)
if Config.thirdPersonShowBody then L.revealBody(character)end
if Config.spinShowLocal and spinApplied then
local root=character:FindFirstChild(__cc20d({58,38,16,39,103,239,170,113,252,205,167,243,105,203,33,193},{0x41324681,0x7A0B10B8,0xE9F49275}))
if root then
viewRoot=root
viewReal=root.CFrame
root.CFrame=viewReal*spinOffset
end
end
end
L.saveLighting=function()
savedLighting={
Brightness=lightingService.Brightness,ClockTime=lightingService.ClockTime,
FogStart=lightingService.FogStart,FogEnd=lightingService.FogEnd,
GlobalShadows=lightingService.GlobalShadows,Ambient=lightingService.Ambient,
OutdoorAmbient=lightingService.OutdoorAmbient,ExposureCompensation=lightingService.ExposureCompensation,
}
end
L.restoreLighting=function()
if savedLighting then
for property,value in pairs(savedLighting)do
pcall(function()lightingService[property]=value end)
end
savedLighting=nil
end
for atmosphere,density in pairs(savedAtmospheres)do
pcall(function()atmosphere.Density=density end)
end
table.clear(savedAtmospheres)
end
L.setLighting=function(property,value)
if lightingService[property]~=value then lightingService[property]=value end
end
L.updateFullbright=function()
if not Config.fbEnabled then
if savedLighting or next(savedAtmospheres)then L.restoreLighting()end
return
end
if not savedLighting then L.saveLighting()end
L.setLighting(__cc20d({76,51,141,110,91,154,13,29,24,255},{0x4E6C7161,0x325CCC9C,0x3B978EB8}),Config.fbBrightness)
L.setLighting(__cc20d({135,99,103,141,162,62,86},{0xF4F56911,0x39EC1ADC,0x1B564E20}),FULLBRIGHT_AMBIENT)
L.setLighting(__cc20d({86,11,68,186,175,193,233,245,204,247,196,133,100,221},{0x0F07D9A6,0x68E86E5C,0xF7812239}),FULLBRIGHT_AMBIENT)
L.setLighting(__cc20d({41,79,213,52,94,139,163,223,191,242,113,36,54,133,224,176,100,188,237,70},{0x1086D107,0xBFEA58A5,0x9874F565}),0)
if Config.fbDaytime then L.setLighting(__cc20d({91,107,64,34,184,210,45,211,126},{0x049F7EC2,0x6CEE187B,0xEC1EAC80}),FULLBRIGHT_CLOCK_TIME)end
if Config.fbNoShadows then L.setLighting(__cc20d({40,66,143,143,103,4,45,44,69,199,165,69,60},{0x0012359A,0xB07FFF66,0x64C330B4}),false)end
if Config.fbNoFog then
L.setLighting(__cc20d({235,248,175,170,240,88,137,235},{0xD432165C,0x2D764CC7,0x424B58F8}),1e9)
L.setLighting(__cc20d({253,252,83,141,165,151},{0x915675B9,0xFAC984BF,0xD74A5060}),1e9)
for _,child in ipairs(lightingService:GetChildren())do
if child:IsA(__cc20d({94,222,145,195,164,114,57,92,214,137},{0x9A2328AD,0xC7283CD7,0x75B05634}))then
if savedAtmospheres[child]==nil then savedAtmospheres[child]=child.Density end
if child.Density~=0 then child.Density=0 end
end
end
else
for atmosphere,density in pairs(savedAtmospheres)do
pcall(function()atmosphere.Density=density end)
end
table.clear(savedAtmospheres)
if savedLighting then
L.setLighting(__cc20d({204,68,125,54,144,121,12,1},{0x17F50F12,0x60E10686,0x0E3C3B74}),savedLighting.FogStart)
L.setLighting(__cc20d({211,154,140,162,202,193},{0x22F439FE,0x7B0C5282,0x5E20F607}),savedLighting.FogEnd)
end
end
if savedLighting then
if not Config.fbNoShadows then L.setLighting(__cc20d({168,213,150,247,98,171,140,195,126,1,46,198,203},{0x7E63C6A0,0xDCDA2E74,0xAF352959}),savedLighting.GlobalShadows)end
if not Config.fbDaytime then L.setLighting(__cc20d({74,135,152,246,139,211,22,5,200},{0xAF7F9209,0xD7AF088D,0x5E7F5C0E}),savedLighting.ClockTime)end
end
end
L.updateLowGravity=function()
if not Config.lowGravityEnabled then
if savedGravity then
workspaceService.Gravity=savedGravity
savedGravity=nil
end
return
end
if not savedGravity then savedGravity=workspaceService.Gravity end
local target=savedGravity*Config.lowGravityScale
if workspaceService.Gravity~=target then workspaceService.Gravity=target end
end
L.updateBhop=function()
if not Config.bhopEnabled then return end
local character=localPlayer.Character
local humanoid=character and character:FindFirstChildOfClass(__cc20d({165,97,163,222,217,28,47,5},{0xF28C4239,0x77C14D02,0xBBC2679B}))
if not humanoid or humanoid.Health<=0 then return end
if not isrbxactive()or userInputService:GetFocusedTextBox()then return end
if window and window:isMouseOver()then return end
if humanoid.FloorMaterial~=Enum.Material.Air and userInputService:IsKeyDown(Enum.KeyCode.Space)then
humanoid.Jump=true
end
end
L.updateSpeed=function(deltaTime)
if Config.flyEnabled then return end
local character=localPlayer.Character
local root=character and character:FindFirstChild(__cc20d({5,141,4,112,143,70,194,242,38,97,63,121,199,26,97,98},{0xE55B43CB,0x265CAD66,0x4A8F6A6F}))
local humanoid=character and character:FindFirstChildOfClass(__cc20d({114,226,231,213,12,92,54,0},{0x3474CCF9,0xB25775CE,0x4CFCC931}))
if not(root and humanoid)or humanoid.Health<=0 or humanoid.Sit then
currentSpeedBoost=0
return
end
if not Config.speedEnabled then
currentSpeedBoost=0
return
end
if not isrbxactive()or(window and window:isMouseOver())then return end
local direction=humanoid.MoveDirection
if direction.Magnitude<0.1 then
currentSpeedBoost=0
return
end
local targetExtra=math.max(Config.speedValue-humanoid.WalkSpeed,0)
if not Config.speedAccelEnabled then
root.CFrame+=direction*targetExtra*deltaTime
return
end
local airborne=humanoid.FloorMaterial==Enum.Material.Air
if airborne then
currentSpeedBoost=math.min(currentSpeedBoost+Config.speedAccelRate*deltaTime,targetExtra)
end
root.CFrame+=direction*math.min(currentSpeedBoost,targetExtra)*deltaTime
end
L.updateFly=function(deltaTime)
if not Config.flyEnabled then return end
local character=localPlayer.Character
local root=character and character:FindFirstChild(__cc20d({37,120,149,247,193,193,74,125,87,96,214,178,202,85,248,46},{0x8E5B5A74,0x4A552114,0x21A2D011}))
local humanoid=character and character:FindFirstChildOfClass(__cc20d({222,14,226,216,146,0,21,179},{0xFE47BE1C,0xEB7D75E0,0xBFA57E95}))
if not(root and humanoid)or humanoid.Health<=0 or humanoid.Sit then return end
if not isrbxactive()or userInputService:GetFocusedTextBox()then return end
local cframe=currentCamera.CFrame
local move=Vector3.zero
if userInputService:IsKeyDown(Enum.KeyCode.W)then move+=cframe.LookVector end
if userInputService:IsKeyDown(Enum.KeyCode.S)then move-=cframe.LookVector end
if userInputService:IsKeyDown(Enum.KeyCode.D)then move+=cframe.RightVector end
if userInputService:IsKeyDown(Enum.KeyCode.A)then move-=cframe.RightVector end
if userInputService:IsKeyDown(Enum.KeyCode.Space)then move+=Vector3.yAxis end
if userInputService:IsKeyDown(Enum.KeyCode.LeftControl)then move-=Vector3.yAxis end
root.AssemblyLinearVelocity=Vector3.zero
if move.Magnitude<0.01 then return end
root.CFrame+=move.Unit*Config.flySpeed*deltaTime
end
L.removeChams=function(player)
local highlight=chamObjects[player]
if not highlight then return end
pcall(function()highlight:Destroy()end)
chamObjects[player]=nil
end
L.updateChamsPlayer=function(player,isSelf)
local character=player.Character
local humanoid=character and character:FindFirstChildOfClass(__cc20d({57,194,111,26,198,196,8,208},{0xE137898F,0xE2248FED,0x3D87945C}))
local root=character and character:FindFirstChild(__cc20d({129,163,114,247,216,250,19,95,14,0,177,112,62,96,39,123},{0xB6BE0D31,0x71DB5619,0x5EEB0348}))
if not(humanoid and root)or humanoid.Health<=0 then
L.removeChams(player)
return
end
local teammate=not isSelf and L.isTeammate(player)
if teammate and Config.chamsHideTeam then
L.removeChams(player)
return
end
if(root.Position-currentCamera.CFrame.Position).Magnitude>Config.chamsDistance then
L.removeChams(player)
return
end
local highlight=chamObjects[player]
if not highlight or highlight.Adornee~=character then
L.removeChams(player)
highlight=Instance.new(__cc20d({91,133,210,110,27,151,157,164,106},{0xA79572AC,0x7532E565,0x58EC1448}))
highlight.Adornee=character
highlight.Parent=gethui and gethui()or coreGuiService
chamObjects[player]=highlight
end
local color=teammate and TEAM_COLOR or Color3.fromRGB(Config.chamsRed,Config.chamsGreen,Config.chamsBlue)
highlight.FillColor=color
highlight.FillTransparency=Config.chamsFillTransparency
highlight.OutlineColor=color
highlight.OutlineTransparency=Config.chamsOutline and Config.chamsOutlineTransparency or 1
highlight.DepthMode=Config.chamsThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
end
L.updateChams=function()
if not Config.chamsEnabled then
for player in pairs(chamObjects)do L.removeChams(player)end
return
end
for _,player in ipairs(playersService:GetPlayers())do
if player==localPlayer then
if Config.chamsShowSelf and Config.thirdPersonEnabled then
L.updateChamsPlayer(player,true)
else
L.removeChams(player)
end
else
L.updateChamsPlayer(player)
end
end
end
L.newDrawing=function(className,properties)
local object=Drawing.new(className)
for key,value in pairs(properties)do object[key]=value end
return object
end
L.createEsp=function()
return{
boxOutline=L.newDrawing(__cc20d({44,6,123,235,74,30},{0xFA809DC3,0x5FA2FCED,0xA5F1FB42}),{Thickness=3,Filled=false,Color=Color3.new(0,0,0),Transparency=1,ZIndex=1,Visible=false}),
box=L.newDrawing(__cc20d({116,248,96,205,27,42},{0xBB3D8AD5,0xD189F1D8,0x7F5A0C11}),{Thickness=1,Filled=false,Transparency=1,ZIndex=2,Visible=false}),
healthBack=L.newDrawing(__cc20d({118,232,84,112,237,65},{0x0396AEFA,0xEDD1C249,0xA6A2DF98}),{Thickness=1,Filled=true,Color=Color3.new(0,0,0),Transparency=1,ZIndex=1,Visible=false}),
healthFill=L.newDrawing(__cc20d({233,47,110,85,77,253},{0xDB36B9AE,0xC2FCDAFC,0x5396A5B6}),{Thickness=1,Filled=true,Transparency=1,ZIndex=2,Visible=false}),
name=L.newDrawing(__cc20d({40,211,42,221},{0x97A2D438,0xFB6E77B8,0x5E2B19B2}),{Size=13,Center=true,Outline=true,Font=Drawing.Fonts.Plex,Transparency=1,ZIndex=3,Visible=false}),
distance=L.newDrawing(__cc20d({159,3,114,60},{0xA4C329AE,0x22A5A90E,0x64726B12}),{Size=13,Center=true,Outline=true,Font=Drawing.Fonts.Plex,Transparency=1,ZIndex=3,Visible=false}),
tracer=L.newDrawing(__cc20d({101,222,98,60},{0x4C4889EB,0xB59F288E,0xA765D165}),{Thickness=1,Transparency=1,ZIndex=1,Visible=false}),
}
end
L.hideEsp=function(esp)
for _,object in pairs(esp)do object.Visible=false end
end
L.removeEsp=function(player)
local esp=espObjects[player]
if not esp then return end
for _,object in pairs(esp)do pcall(function()object:Remove()end)end
espObjects[player]=nil
end
L.updateEspPlayer=function(player,esp)
local character=player.Character
local humanoid=character and character:FindFirstChildOfClass(__cc20d({9,28,222,19,57,219,148,107},{0x501E5E41,0xC1D452C9,0x328E30FD}))
local root=character and character:FindFirstChild(__cc20d({228,54,158,224,157,58,229,205,204,163,202,119,15,3,36,130},{0x5BB296D2,0xA553B928,0xF7412F04}))
if not(humanoid and root and humanoid.Health>0)then
L.hideEsp(esp)
return
end
local teammate=L.isTeammate(player)
if teammate and Config.espHideTeam then
L.hideEsp(esp)
return
end
local distance=(root.Position-currentCamera.CFrame.Position).Magnitude
if distance>Config.espDistance then
L.hideEsp(esp)
return
end
local top=currentCamera:WorldToViewportPoint(root.Position+Vector3.new(0,2.6,0))
local bottom=currentCamera:WorldToViewportPoint(root.Position-Vector3.new(0,3.2,0))
if top.Z<=0 or bottom.Z<=0 then
L.hideEsp(esp)
return
end
local color=teammate and TEAM_COLOR or ESP_COLORS[Config.espColor]
local height=math.abs(bottom.Y-top.Y)
local width=height*0.55
local centerX=top.X
local position=Vector2.new(math.floor(centerX-width/2),math.floor(top.Y))
local size=Vector2.new(math.floor(width),math.floor(height))
esp.box.Visible=Config.espBoxes
esp.boxOutline.Visible=Config.espBoxes
esp.box.Color=color
esp.box.Position=position
esp.box.Size=size
esp.boxOutline.Position=position
esp.boxOutline.Size=size
local ratio=humanoid.MaxHealth>0 and math.clamp(humanoid.Health/humanoid.MaxHealth,0,1)or 0
local fillHeight=math.floor(size.Y*ratio)
esp.healthBack.Visible=Config.espHealth
esp.healthFill.Visible=Config.espHealth
esp.healthBack.Position=Vector2.new(position.X-6,position.Y-1)
esp.healthBack.Size=Vector2.new(4,size.Y+2)
esp.healthFill.Position=Vector2.new(position.X-5,position.Y+size.Y-fillHeight)
esp.healthFill.Size=Vector2.new(2,fillHeight)
esp.healthFill.Color=Color3.fromRGB(255,50,50):Lerp(Color3.fromRGB(50,255,90),ratio)
esp.name.Visible=Config.espNames
esp.name.Text=player.Name
esp.name.Color=color
esp.name.Position=Vector2.new(centerX,position.Y-16)
esp.distance.Visible=Config.espDistanceText
esp.distance.Text=string.format(__cc20d({143,237,74,225},{0xE49097B0,0xFDFAA6FA,0x504208E3}),distance)
esp.distance.Color=color
esp.distance.Position=Vector2.new(centerX,position.Y+size.Y+2)
local viewport=currentCamera.ViewportSize
esp.tracer.Visible=Config.espTracers
esp.tracer.Color=color
esp.tracer.From=Vector2.new(viewport.X/2,viewport.Y)
esp.tracer.To=Vector2.new(centerX,position.Y+size.Y)
end
L.updateEsp=function()
if not Config.espEnabled then
for _,esp in pairs(espObjects)do L.hideEsp(esp)end
return
end
for _,player in ipairs(playersService:GetPlayers())do
if player==localPlayer then continue end
local esp=espObjects[player]
if not esp then
esp=L.createEsp()
espObjects[player]=esp
end
L.updateEspPlayer(player,esp)
end
end
L.updateTrigger=function()
local allowed=Config.enabled and L.isActive()and isrbxactive()and not(window and window:isMouseOver())
if Config.fireStyle==__cc20d({149,155,238,211},{0x019C11FA,0x92C0583D,0xA61B06A2})then
local now=os.clock()
if allowed and L.getTargetPlayer()then
lastTargetSeen=now
if not holding and not pending then
pending=true
task.delay(Config.reactionDelay/1000,function()
pending=false
if Config.fireStyle==__cc20d({21,234,215,110},{0xC1849DB8,0x9112C8D5,0x423F5ECA})
and Config.enabled
and L.isActive()
and not(window and window:isMouseOver())
and L.getTargetPlayer()
then
lastTargetSeen=os.clock()
L.startHold()
end
end)
end
elseif holding and(not allowed or now-lastTargetSeen>Config.holdRelease/1000)then
L.stopHold()
end
return
end
if holding then L.stopHold()end
if not allowed or pending then return end
if(os.clock()-lastClick)*1000<Config.clickCooldown then return end
if not L.getTargetPlayer()then return end
pending=true
task.delay(Config.reactionDelay/1000,function()
pending=false
if Config.enabled and L.isActive()and not(window and window:isMouseOver())and L.getTargetPlayer()then
lastClick=os.clock()
L.fire()
end
end)
end
L.onRenderStep=function(deltaTime)
if statusLabel then
local status=__cc20d({10,42,66,60,111,5,238,162},{0x86190EFD,0xD25B3135,0x77FAF065})..((Config.enabled and L.isActive())and __cc20d({66,45,157,170,38,159},{0x181011A5,0xED3CE62C,0x8942FCF5})or __cc20d({142,32,164,214},{0x62F64C27,0x22DDB233,0xC3CFB1BC}))
if holding then status=status..__cc20d({218,159,175,111,236,205,8,134,176,145},{0x8DDE0D00,0x29CE9A2C,0x968720ED})end
if statusLabel.Text~=status then statusLabel.Text=status end
end
L.updateEsp()
L.updateChams()
L.updateFov()
L.updateRage()
L.updateBulletTracers()
L.updateAim()
L.updateAssist()
L.updateTrigger()
L.updateRecoil(deltaTime)
L.updateFullbright()
L.updateLowGravity()
L.updateBhop()
L.updateSpeed(deltaTime)
L.updateFly(deltaTime)
end
L.onInputBegan=function(input,processed)
if not window then return end
if window:handleCapture(input)then return end
if processed then return end
if os.clock()<ignoreInputUntil and L.matchesBind(Config.fireBind,input)then return end
if input.KeyCode==MENU_KEY then
window:toggle()
return
end
if L.matchesBind(Config.aimBind,input)then aimHeld=true end
if thirdPersonCheckbox and L.matchesBind(Config.thirdPersonBind,input)then
thirdPersonCheckbox.set(not thirdPersonCheckbox.get())
end
if flyCheckbox and L.matchesBind(Config.flyBind,input)then
flyCheckbox.set(not flyCheckbox.get())
end
if L.matchesBind(Config.markBind,input)then
L.toggleManualTeammate()
end
if L.matchesBind(Config.bind,input)then
if Config.mode==__cc20d({74,195,244,231,87,46},{0x1F2BE021,0x7BDCDF59,0x6EF9963F})then
toggled=not toggled
elseif Config.mode==__cc20d({47,218,159,44},{0x66AF6BB9,0xC9343D6E,0x4E748163})then
held=true
end
end
end
L.onInputEnded=function(input)
if L.matchesBind(Config.aimBind,input)then aimHeld=false end
if os.clock()<ignoreInputUntil and L.matchesBind(Config.fireBind,input)then return end
if L.matchesBind(Config.bind,input)then held=false end
end
L.setLuaStatus=function(text)
luaMessage=text
if luaStatusLabel then luaStatusLabel.Text=text end
end
L.luaPath=function(name)return LUA_FOLDER..__cc20d({169},{0xCAFE67DF,0xB6554928,0x34EA2622})..name..LUA_EXTENSION end
L.listLuaScripts=function()
local names={}
pcall(function()
if not isfolder(LUA_FOLDER)then return end
for _,path in ipairs(listfiles(LUA_FOLDER))do
local name=path:match(__cc20d({238,90,163,209,213,119,222,217,131,216,29,82,180,155},{0x4F89EEB7,0x035BAB83,0xCA83327A}))
if name then table.insert(names,name)end
end
end)
table.sort(names,function(a,b)return a:lower()<b:lower()end)
return names
end
L.saveLua=function()
local name=L.sanitizeName(selectedLua)
if name==__cc20d({},{0x53F60743,0x85CC4354,0x1FDE0151})then
L.setLuaStatus(__cc20d({172,154,138,57,111,222,57,48,244,10,37,115,192,76,104,22,242,107,52,177,223,170,127,25,191},{0x41A27CAB,0x073D7F6E,0xCF500DD2}))
return
end
local code=luaCodeBox and luaCodeBox.Text or __cc20d({},{0xB16A36A4,0xD740AA5F,0x13CC576B})
local success,saveError=pcall(function()
if not isfolder(LUA_FOLDER)then makefolder(LUA_FOLDER)end
writefile(L.luaPath(name),code)
end)
if not success then
L.setLuaStatus(__cc20d({142,172,252,84,27,194,6,251,129,131,96,245,117},{0x39FB359B,0x07A020AA,0xC3596FC3})..tostring(saveError))
return
end
selectedLua=name
if luaNameBox then luaNameBox.Text=name end
L.setLuaStatus(__cc20d({13,100,183,83,124,206,145},{0xAB519680,0xAE3541CE,0xE623DFA1})..name)
end
L.loadLua=function()
local name=L.sanitizeName(selectedLua)
if name==__cc20d({},{0x6F8FB0B9,0x04CBD329,0x02DBE151})or not isfile(L.luaPath(name))then
L.setLuaStatus(__cc20d({124,238,10,164,128,15,206,124,185,114,7,213,130,22,57,247,120,144},{0xAF62A5A5,0x96147C4E,0x3A497B21})..name)
return
end
local success,code=pcall(readfile,L.luaPath(name))
if not success then
L.setLuaStatus(__cc20d({198,24,180,242,54,100,93,147,185,11,162,159,58},{0xFBD3D0AF,0xA66764B2,0x9D4CF862})..tostring(code))
return
end
if luaCodeBox then luaCodeBox.Text=code end
selectedLua=name
L.setLuaStatus(__cc20d({16,113,78,138,210,3,94,118},{0x60953ACE,0x251EC0AA,0xE3622A6C})..name)
end
L.deleteLua=function()
local name=L.sanitizeName(selectedLua)
if name==__cc20d({},{0xAF690EBB,0x7B01131D,0x8D79D6AA})or not isfile(L.luaPath(name))then
L.setLuaStatus(__cc20d({119,189,165,251,120,170,165,27,207,134,167,143,211,236,199,83,133,30},{0x499EC321,0x11DA04C8,0x500B1B19})..name)
return
end
local success,deleteError=pcall(delfile,L.luaPath(name))
if success then
L.setLuaStatus(__cc20d({69,135,32,10,204,140,128,230,238},{0xCE91073D,0x6003BB2D,0xD45F9315})..name)
else
L.setLuaStatus(__cc20d({43,185,1,106,57,14,177,123,85,112,123,65,85,236,80},{0x622040A4,0xA6E3CFEF,0xFE21E503})..tostring(deleteError))
end
end
L.runLua=function()
local code=luaCodeBox and luaCodeBox.Text or __cc20d({},{0xAA804BB7,0x5AD71682,0x7ABC155B})
local fn,compileError=loadstring(code)
if not fn then
L.setLuaStatus(__cc20d({234,156,212,186,167,64,22,155,252,25,90,250,236,26,31},{0xEA3B2283,0xCB35B777,0xDF73055B})..tostring(compileError))
return
end
local success,runError=pcall(fn)
if success then
L.setLuaStatus(__cc20d({242,19,38,73,116},{0xD9F743C6,0xD76BAA03,0x4A6C2BD0})..selectedLua)
else
L.setLuaStatus(__cc20d({10,176,22,174,69,224,168,187,237,133,118},{0x8D607993,0x18CD7C04,0x5CCF06A7})..tostring(runError))
end
end
L.runLuaFile=function(name)
local path=L.luaPath(L.sanitizeName(name))
if not isfile(path)then return end
local success,code=pcall(readfile,path)
if not success then return end
local fn,compileError=loadstring(code)
if not fn then
warn(__cc20d({119,75,0,147,30,178,33,238,201,212,88,25,92,4,63,209,243,224,216,237,180,23,198,149,83,155,24},{0x2AF2D92B,0x8752D293,0x2B6225E7})..tostring(compileError))
return
end
local ran,runError=pcall(fn)
if not ran then warn(__cc20d({62,153,138,243,215,246,174,153,189,74,252,40,245,97,128,167,125,182,171},{0x879FCF29,0x3CE7483D,0x91C47369})..tostring(runError))end
end
do
local ml,mr=U.columns(mainRoot)
local general=U.card(ml,__cc20d({84,254,46,120,114,230,184},{0x36FF8581,0x43BF4CDF,0xD831B62C}))
U.checkbox(general,__cc20d({54,195,81,109,34,222,108,186,55,180,75,185},{0xA87974B1,0x7891F241,0x55167E9F}),__cc20d({45,228,167,30,133,146,166},{0x185912AB,0xC74663C5,0xB3E3D58D}),Config.enabled,{onChange=function(v)Config.enabled=v end})
U.checkbox(general,__cc20d({154,235,161,22,185,182,88,74,15,18,42,172,18,6},{0xF2C9779B,0x0BFB4D96,0xD26DFFD9}),__cc20d({21,209,89,83,177,89,130,220,102,164},{0xC55D5960,0xB0DB848C,0x62D9107B}),Config.teamCheck,{onChange=function(v)Config.teamCheck=v end})
U.checkbox(general,__cc20d({6,46,154,196,238,60,162,150,238,214,142,139,169,235},{0xD7F7225D,0x30FE2065,0x9A2FB493}),__cc20d({181,5,97,41,233,216,25,116,140,32},{0x6386A473,0xA0229C5D,0x6E78494D}),Config.wallCheck,{onChange=function(v)Config.wallCheck=v end})
U.checkbox(general,__cc20d({148,60,40,83,58,165,218,220,42,176,133,51,238,92},{0x5069E1A0,0xCB0223B3,0x316359D1}),__cc20d({34,188,3,237,234,60,154,248,64,81,242,176,4,59,244,40,215},{0xE71C829B,0x5870905D,0x4BECECD8}),Config.smartTeam,{onChange=function(v)Config.smartTeam=v end})
U.keyfield(general,__cc20d({232,209,50,92,221,226,118,190,167,25,89,0,110},{0xA3875B55,0x88C320B5,0x8941AD23}),__cc20d({165,94,55,115,151,111,1,62,52,182,199,36,13,16,73,60,25},{0x99173D68,0x13CE7A8E,0xB874DDA0}),Config.markBind,{onChange=function(v)Config.markBind=v end})
U.button(general,__cc20d({35,146,131,251,223,135,241,204,219,26,205,233,183,121,11,65,236,194,123,112,210,89},{0xA9E1C012,0xE9E193CE,0xB6B7AD4D}),false).MouseButton1Click:Connect(function()
table.clear(manualTeammates)
end)
U.button(general,__cc20d({60,50,214,33,212,207,49,149,39,86,187,30,225,99,182},{0xD8590C8D,0xA3BE3688,0x3CDD1B1D}),false).MouseButton1Click:Connect(L.printTeamInfo)
local trig=U.card(mr,__cc20d({68,11,228,27,243,234,161},{0x353069F2,0xC62FF896,0xA7356D32}))
U.keyfield(trig,__cc20d({100,6,53,137,29,66,172,49,155},{0x950266E1,0x0C38506F,0x127C75AF}),__cc20d({115,150,143,4,204,148,99,77,46,25,226},{0xC98D3DA0,0x84786681,0x27DE43CB}),Config.bind,{onChange=function(v)Config.bind=v;held=false end})
U.dropdown(trig,__cc20d({66,247,168,254,93,84,223,198,42},{0x7A96877E,0x17E972AB,0xAC56B11C}),__cc20d({215,148,59,127},{0x0B07DF6A,0x2A6D0B2D,0x95202F2E}),MODES,Config.mode,{onChange=function(v)Config.mode=v;held=false end})
statusLabel=U.new(__cc20d({28,139,60,199,12,156,49,14,89},{0x4D7868B0,0xC818564D,0xD1E8C035}),{
Text=__cc20d({119,184,124,187,196,145,69,182,41,144,126,11},{0x7218DE13,0x1645F014,0xC24003BB}),Font=F.reg,TextSize=11,TextColor3=T.sub,
BackgroundTransparency=1,Size=UDim2.new(1,0,0,14),
TextXAlignment=Enum.TextXAlignment.Left,
},trig)
U.order(statusLabel)
U.keyfield(trig,__cc20d({81,242,139,232,108,34,49,180,39,20,46,253,66},{0xA9F78AAE,0x08CBA276,0x008C9212}),__cc20d({119,54,30,129,253,228,166,140,13,210},{0x75A81721,0xF6A4C216,0xC7D4E942}),Config.fireBind,{
onChange=function(v)
Config.fireBind=v or{kind=__cc20d({30,213,117,115,227,120,205,214,179,211,91,76,20},{0x83E1892B,0x8B540B89,0x71EE56D7}),code=Enum.UserInputType.MouseButton1}
L.stopHold()
end,
})
U.dropdown(trig,__cc20d({29,51,152,70,253,16,210,58,17,85,76,179,8,105},{0x2A80E11A,0xFBC8533E,0xA9C40FDA}),__cc20d({113,56,170,226,116,28,186,181,155,97},{0x066B15B2,0x65E9F881,0xB8E97A7B}),FIRE_STYLES,Config.fireStyle,{onChange=function(v)Config.fireStyle=v;L.stopHold()end})
U.dropdown(trig,__cc20d({132,106,213,236,75,129,17,238,240,148},{0x3AAECDEF,0x83268CE3,0x1B8FF2C1}),__cc20d({214,156,168,226,166,201},{0x2C6A273B,0x3891B617,0x63EC3B1D}),AIM_MODES,Config.aimAt,{onChange=function(v)Config.aimAt=v end})
U.slider(trig,__cc20d({64,67,86,226,183,122,109,192,72,201,10,23},{0x046EF4F3,0x9970D8B7,0xD8E4D2B5}),__cc20d({240,165,206,131,139,11,30,19,69,172,55,202},{0x3621B5BC,0xBD899B7D,0x32E85EA8}),50,2000,Config.maxDistance,{unit=__cc20d({168,248,5,156,102,37},{0x4551A7BC,0x8CB15D31,0x672704A4}),step=10,onChange=function(v)Config.maxDistance=v end})
end
do
local soft=U.card(aimRoot,__cc20d({102,46,221,234,170,122,223,3},{0x80EDA355,0x27EAE22A,0xD5E49169}))
U.checkbox(soft,__cc20d({79,232,116,182,158,229,179,136,105,55,208},{0xC17CB552,0x73D92B6B,0xD1011EFE}),__cc20d({157,201,162,219,171,37,137},{0x23005CEB,0xF58490FA,0x9D61DF2E}),Config.aimEnabled,{onChange=function(v)Config.aimEnabled=v end})
U.checkbox(soft,__cc20d({41,242,151,205,237,72,208,48,247,35,58},{0x0539176B,0xF0307EA1,0xF7872AEC}),__cc20d({220,0,125,247,169,5,8,20,13,149,184,174,147},{0x34708BAC,0x28E426EF,0x00A536F6}),Config.aimVisibleCheck,{onChange=function(v)Config.aimVisibleCheck=v end})
U.checkbox(soft,__cc20d({125,79,177,40,252,23,118,184,99,69,5},{0x6EC628BF,0xEA461FF1,0xDC2A3606}),__cc20d({122,211,59,188,140,220,243,71},{0xCB8A5AB5,0x05084E96,0x5AFB32F4}),Config.aimShowFov,{onChange=function(v)Config.aimShowFov=v end})
U.keyfield(soft,__cc20d({137,122,45,228,193,33,181,159},{0x72A0E61D,0x9B488EB3,0x530A2F36}),__cc20d({39,18,125,53,123,207,109},{0x40ECDDA2,0x155A1F3E,0xCF6FE7B9}),Config.aimBind,{onChange=function(v)Config.aimBind=v;aimHeld=false end})
U.dropdown(soft,__cc20d({117,79,120,135,209,167,163,83},{0x38FCDC10,0x343C6DD5,0x08994F9F}),__cc20d({169,0,87,186,5,27},{0xC54A3044,0xF44427E1,0x79AB8E88}),AIM_PARTS,Config.aimPart,{onChange=function(v)Config.aimPart=v end})
U.slider(soft,__cc20d({229,116,108,130,80,85,71},{0x96FD8BEF,0x01CE5EC6,0xEDE766C6}),__cc20d({20,151,10,37,209,63,126,90,15,18},{0x2273651B,0xB6B00502,0x9B0F8FC2}),20,600,Config.aimFov,{unit=__cc20d({63,88,91},{0x8DA80D14,0x27B5F768,0xD941D2C5}),step=5,onChange=function(v)Config.aimFov=v end})
U.slider(soft,__cc20d({172,240,35,159,50,140,248,131,241,109},{0x283E9632,0x2CA51558,0xF33A6D63}),__cc20d({127,154,136,168,235,150,87,232,80},{0xE63E6226,0x1596FC74,0xB619C46E}),1,30,Config.aimSmoothing,{onChange=function(v)Config.aimSmoothing=v end})
U.slider(soft,__cc20d({149,122,36,221,168,21,6,208},{0x410344D0,0x9BA1368F,0x4F42BC56}),__cc20d({127,68,208,165,26,85,110,171,113,166,16,13},{0xCF8CC5E9,0xFB9352DD,0x83899C06}),50,2000,Config.aimDistance,{unit=__cc20d({20,13,56,253,69,141},{0x7F062EC4,0xED1507F1,0x3AA91F40}),step=10,onChange=function(v)Config.aimDistance=v end})
local assist=U.card(aimRoot,__cc20d({202,50,153,85,221,235,132,229,102,160},{0xC727B3BA,0x304063CF,0xBDEC5872}))
U.checkbox(assist,__cc20d({19,223,84,199,60,128,170,108,56,113,82,134,98,39},{0x59E6F66F,0x12FC3DFF,0x329677C4}),__cc20d({26,123,64,86,204,46,43},{0xC7DEFD85,0x6159EB77,0x672CA07B}),Config.assistEnabled,{onChange=function(v)Config.assistEnabled=v;if not v then assistTarget=nil end end})
U.checkbox(assist,__cc20d({35,25,29,104,119,106,99,64,24,182,81,133,130,76,56,131},{0xC3932980,0x0A412284,0x1D923485}),__cc20d({16,153,8,160,232,131,46,19,10,122},{0x8F7C5943,0x54F30D3A,0x28C67398}),Config.assistTeamCheck,{onChange=function(v)Config.assistTeamCheck=v end})
U.checkbox(assist,__cc20d({195,72,163,147,165,164,66,112,139,51,247,140,53,112},{0x48AA747F,0x254C0153,0x68587771}),__cc20d({189,171,208,111,25,92,70,178,44,37,129,163,160},{0x72B0C024,0x8ED48EE6,0x6F7A7855}),Config.assistVisibleCheck,{onChange=function(v)Config.assistVisibleCheck=v end})
U.checkbox(assist,__cc20d({118,25,16,39,136,132,16,154,72,238,199,68,27,143,79,141,21},{0x769C8557,0x94DF79B5,0xA028C9E2}),__cc20d({148,41,143,152,78,187,85,157,104,155,164},{0xEDB93E61,0xF54EE9D3,0x97306005}),Config.assistShowRadius,{onChange=function(v)Config.assistShowRadius=v end})
U.slider(assist,__cc20d({222,1,236,163,246,138,196,192,190,223,157,227,9,71,100},{0xB3062D60,0x8501373C,0xE0AED509}),__cc20d({197,162,24,252,137,130,77,111},{0x60944D4D,0x2E8F0016,0xB266A334}),1,40,Config.assistStrength,{unit=__cc20d({241},{0x960555D9,0xA2A1F639,0x25766A7B}),onChange=function(v)Config.assistStrength=v end})
U.slider(assist,__cc20d({205,83,14,117,49,169,255,153,13,179,31,113,139,89},{0x1509BA62,0x1E6CCF4A,0xE78CCF98}),__cc20d({78,163,224,130,94,102,75,151,170,55,82,200,174,206},{0x9FC263E7,0xED542964,0xE716DF7F}),20,300,Config.assistRadius,{unit=__cc20d({98,165,170},{0x4D403E97,0x93975EE0,0xD1E79DE1}),step=5,onChange=function(v)Config.assistRadius=v end})
U.slider(assist,__cc20d({184,186,27,133,64,143,101,121,155,112,249,217},{0x6B842F4C,0xA5ADD462,0xD7B5D30A}),__cc20d({235,135,192,188,68,27,107,116,33,30,171,195},{0xC2742F72,0x1E1CC381,0x8B627855}),40,500,Config.assistBreakRadius,{unit=__cc20d({44,194,29},{0xBCBAF63F,0xE1E486D3,0x4B7E6149}),step=5,onChange=function(v)Config.assistBreakRadius=v end})
U.slider(assist,__cc20d({171,80,153,66,13,229,37,129,133,82,47},{0x19213995,0x38955258,0x72F46B90}),__cc20d({208,181,89,127,180,116,153,127,98,79,117,179,224,242,125},{0x62EE2F85,0x5E715D9E,0x06FEE9F6}),50,2000,Config.assistDistance,{unit=__cc20d({93,65,220,223,238,172},{0xA0F93FA4,0xF3CF7CFE,0x4980029E}),step=10,onChange=function(v)Config.assistDistance=v end})
end
do
local c=U.card(recoilRoot,__cc20d({60,157,47,119,215,231,96,144,210},{0xF9A3D5F3,0x91675CC9,0x87ADB0A1}))
U.checkbox(c,__cc20d({248,81,87,15,248,77,98,228,50,199,40,3,57,131},{0x70D812D9,0x9A98F56F,0x36625DCA}),__cc20d({10,171,186,253,157,34,138},{0xABAF33C7,0x90984FE2,0x3C7EE76D}),Config.recoilEnabled,{onChange=function(v)Config.recoilEnabled=v end})
U.checkbox(c,__cc20d({205,96,165,246,92,174,155,230,7,102,221,21,223},{0x023DDB50,0xEE588F3E,0x701E8686}),__cc20d({26,227,153,238,3,34,224,132,220,254,212,230,144,87,132,46,171,47},{0xEEC85BB2,0x0F08AC7C,0x2E6EBB26}),Config.recoilManual,{onChange=function(v)Config.recoilManual=v end})
U.checkbox(c,__cc20d({33,149,156,29,164,162,92,204,71,132},{0xF9113C54,0x27F30453,0x6CB24E11}),__cc20d({132,166,174,52,219,122,50,126,219,103,164,212,180,198,202,13,228},{0xC4F94D6F,0x199BD228,0x65908AAC}),Config.recoilBot,{onChange=function(v)Config.recoilBot=v end})
U.slider(c,__cc20d({126,176,194,131,154,232,208,73},{0x5BBCCF7B,0xD82EC3C5,0x58F7B440}),__cc20d({24,97,220,138,186,1,17,50,102},{0x56B096D4,0x7A2BDFB0,0xC3F8A82D}),0,30,Config.recoilY,{step=0.5,format=function(v)return string.format(__cc20d({103,36,211,40,65,27,51},{0xEB5666E8,0x2BF9D487,0x76415FD9}),v)end,onChange=function(v)Config.recoilY=v end})
U.slider(c,__cc20d({8,111,104,110,106,205,43,167},{0x674B8D5B,0x75ACD105,0xEE7CCC6C}),__cc20d({1,167,176,184,159,110,80,129,143,111,191,102,126},{0xAE175C84,0xEB7A96B6,0x1FD2C0BB}),-10,10,Config.recoilX,{step=0.5,format=function(v)return string.format(__cc20d({130,206,229,94,187,238,72},{0x31A28DF4,0x41BDDA89,0xAA417A24}),v)end,onChange=function(v)Config.recoilX=v end})
U.slider(c,__cc20d({171,238,179,240,137,68,196,212,190,49,245},{0x22D5DCE3,0x690DDE8F,0x3D3479E6}),__cc20d({87,64,172,126,27,247,204},{0x4A515033,0x55915E46,0x69DDD6AC}),0,1000,Config.recoilRamp,{unit=__cc20d({26,151,155},{0x22E2E5C4,0x51E03D0C,0xDB666794}),step=25,onChange=function(v)Config.recoilRamp=v end})
end
do
local spin=U.card(rageRoot,__cc20d({215,193,13,50,14,47,142},{0xA1DADA02,0x56421D7B,0x50CD6FC2}))
U.checkbox(spin,__cc20d({211,49,235,125,25,105,46,216,9,49,69,134,137,238,108,44,64},{0x4E6FCE05,0x393638C8,0xDC0B93AE}),__cc20d({1,168,188,157,25,165,73},{0x6D7023A8,0x8FDA20B8,0x9778B4F1}),Config.spinEnabled,{onChange=function(v)Config.spinEnabled=v end})
U.checkbox(spin,__cc20d({196,228,181,47,214,67,25,42,178,135,6,72,66,86,96,78,203,80,177,84,171,215},{0x8B782BB0,0x5EDBDF7D,0xD5AEA29E}),__cc20d({208,130,227,238,239,221,215,180,0,247,67,143,205,233,16,179,214,186,207,64,59,144,12,161},{0xA8467F12,0xBE5BACE9,0xEDAB35E5}),Config.spinPauseOnShoot,{onChange=function(v)Config.spinPauseOnShoot=v end})
U.checkbox(spin,__cc20d({193,109,231,206,170,72,170,47,172,255,45,59,12,155,179,180,56,24,71},{0xE4297DAB,0x3D6A7983,0x87722303}),__cc20d({26,165,108,143,233,254,84,50,100,82,70,248,190,172,75,155,229,90,209,90,77,90,56,50,221,249},{0xC99A76E5,0xDA0D19E0,0xE4BE926D}),Config.spinShowLocal,{onChange=function(v)Config.spinShowLocal=v end})
U.dropdown(spin,__cc20d({137,18,133,80,177,20,21,238,104,208,105,225,190,66},{0x7E1C38EA,0x649E3558,0x929B18A2}),__cc20d({150,146,193,7},{0x6114C065,0xD05A0BFE,0x36B6721A}),SPIN_MODES,Config.spinMode,{onChange=function(v)Config.spinMode=v end})
U.checkbox(spin,__cc20d({145,111,157,111,5,202,146,182,124,146,252,141,57,1},{0xEB7C295D,0xD9ED3AAD,0xE22ED733}),__cc20d({226,102,212,103,230,203,183,233,75,199,52,86,255,90,230,18,10,211,60,135,40,215,84,10,99,47},{0xF6D1438E,0xBA70FC8F,0x062BDEB5}),Config.spinAutoDirection,{onChange=function(v)Config.spinAutoDirection=v end})
U.slider(spin,__cc20d({147,4,78,5,29,68,83,235,96,172,61,124,57,139,33},{0x3835EAD9,0xD08C35D3,0x033402D5}),__cc20d({251,196,50,20,132,123,29,15,153,34},{0xC7409D22,0x29F60F80,0x2DF2FF04}),60,3600,Config.spinSpeed,{unit=__cc20d({244,149,145,177,34,84},{0x73E05998,0xA1D32165,0xDE883742}),step=60,onChange=function(v)Config.spinSpeed=v end})
U.slider(spin,__cc20d({243,160,122,194,222,160,144,2,15,16,135,176,146,108,148,216},{0x958AAD93,0x352ADA92,0xED2F7951}),__cc20d({52,238,176,202,67,65,162,60,199,216,17,244},{0x49843C06,0xF2D3648D,0x23A61B43}),10,180,Config.spinJitter,{unit=__cc20d({207,140,27,151},{0x16B271CC,0x0506DBD7,0x05A5214C}),step=10,onChange=function(v)Config.spinJitter=v end})
U.slider(spin,__cc20d({233,133,177,101,234,251,208,244,67,172,131,117,22,30,240,4},{0x132A0750,0x064CF4CF,0x3BAF7369}),__cc20d({214,208,88,177,222,49,117,199,31,18,181,55},{0x53BCC6E2,0x8FE9E786,0xC5AAD993}),-180,180,Config.spinStaticAngle,{unit=__cc20d({178,181,85,17},{0xD2468990,0xA9529929,0x446043A8}),step=5,onChange=function(v)Config.spinStaticAngle=v end})
U.slider(spin,__cc20d({250,41,208,35,18,254,175,81,79,175,204,140,204,250,243,162},{0x9F142877,0xD9CFB606,0x0AEDC04D}),__cc20d({85,151,11,60,103,143,148,238,205,171,60,176,250,113,170,43},{0x9A59A942,0x8D10DC10,0x9BE78024}),100,2000,Config.spinRandomInterval,{unit=__cc20d({228,252,111},{0xA6920FAC,0x4612A03C,0x44D5DE79}),step=50,onChange=function(v)Config.spinRandomInterval=v end})
U.slider(spin,__cc20d({35,98,116,77,33,18,96,26,22,86,173,62,35,8,57,198},{0xEA2DA8A5,0x62927D6F,0xC6F35479}),__cc20d({122,143,205,148,210,33,49,114,12,42,97,113,16,237},{0xE054F170,0x205AD176,0xB51C0AE7}),0,500,Config.spinSmoothing,{unit=__cc20d({115,190,151},{0x3C1D8746,0x5D313EFF,0x76BBBAF2}),step=10,onChange=function(v)Config.spinSmoothing=v end})
U.slider(spin,__cc20d({46,174,232,76,66,185,25,20,86,186,149,31,91,15,248,24,33,143,114},{0x69E7FE48,0x27604443,0x96BE9A46}),__cc20d({103,187,12,164,88,198,60,111,198,121,160,94,151,27,246,21,168},{0xFF1F10B8,0xDD18D153,0xB8256109}),-90,90,Config.spinLeanPitch,{unit=__cc20d({57,101,180,216},{0xDAE18633,0xBF5B3309,0x90473043}),step=5,onChange=function(v)Config.spinLeanPitch=v end})
U.slider(spin,__cc20d({202,210,127,22,63,92,54,12,182,228,244,106,63,164,183,229,6,22},{0xC2AE2A77,0x0CF0404F,0xBBE0C4B7}),__cc20d({22,58,198,243,232,43,55,216,86,218,174,32,30},{0xEC36A3B2,0x005BCEB5,0x9985F004}),-90,90,Config.spinLeanRoll,{unit=__cc20d({242,6,94,76},{0x7AD3B987,0xECAAC922,0x315770C1}),step=5,onChange=function(v)Config.spinLeanRoll=v end})
local auto=U.card(rageRoot,__cc20d({8,216,55,15,62,93,198,203,172,205},{0xD01667B0,0x2AF58634,0xE0A9672B}))
U.checkbox(auto,__cc20d({8,61,253,97,227,178,46,107,203,160,214,10,151,218,159,29,250},{0xF18D2118,0xD8705401,0xA0EE67B2}),__cc20d({32,60,31,153,25,165,138},{0x608C3A0A,0x7366459D,0x12D2F820}),Config.rageEnabled,{onChange=function(v)
Config.rageEnabled=v
if not v then rageEngaged=false;silentTarget=nil end
end})
U.dropdown(auto,__cc20d({108,228,186,128,245,25,23,6,139,85,43,200,0,68},{0x33BD8C4B,0x7382E59F,0x9A677A80}),__cc20d({242,98,62,106,146,139,116,147,153,0},{0xFEF0C76C,0xA3CBCA44,0x9467D465}),RAGE_MODES,Config.rageMode,{onChange=function(v)Config.rageMode=v end})
U.checkbox(auto,__cc20d({57,252,85,75,99,14,44,6,212,238,240,37,82,102,83,203,146,42,105},{0xB4CA3784,0xA16365F8,0x99B5E699}),__cc20d({12,11,36,216,19,212,125,58,99,102},{0x9EE15824,0x20361780,0x0685E976}),Config.rageTeamCheck,{onChange=function(v)Config.rageTeamCheck=v end})
U.checkbox(auto,__cc20d({142,207,114,244,182,146,239,62,224,160,139,77,106,175,115,40,119,86,223},{0x14802BD4,0x1245F6B8,0x2ABD7361}),__cc20d({11,215,237,140,236,163,25,9,93,66},{0xDA86CD66,0x095797A9,0xAA7CBD75}),Config.rageWallCheck,{onChange=function(v)Config.rageWallCheck=v end})
U.checkbox(auto,__cc20d({180,38,112,41,120,180,213,243,164,137,250,43,120,169,155,2,223,166},{0x2FDBEA70,0xDD872C50,0x23769D02}),__cc20d({155,217,39,56,62,55,54,124,222,77,71,137,71,10,83,63,226,140,197,176,246,193},{0xADBDE864,0x6F265A37,0x2A0DEB94}),Config.rageWallbang,{onChange=function(v)Config.rageWallbang=v end})
U.checkbox(auto,__cc20d({56,23,65,208,153,74,210,26,249,217,46,213,238,164,170,207},{0x3D1F597E,0xF5C738BA,0x6DA14001}),__cc20d({67,38,15,153,33,253,21,181,234,120,16,138,68},{0x45FBB5A0,0x22DAEFD4,0xEA0A6462}),Config.rageBulletTracer,{onChange=function(v)Config.rageBulletTracer=v end})
U.dropdown(auto,__cc20d({47,240,94,233,231,54,156,237,190,74,215,44,91,108},{0x2F92FFA3,0xA08D10BF,0xF3B6C692}),__cc20d({95,146,229,115,149,47},{0x5BC5B9E5,0x339D49F8,0x4F79B244}),AIM_PARTS,Config.ragePart,{onChange=function(v)Config.ragePart=v end})
U.slider(auto,__cc20d({249,246,253,4,49,5,85,124,64,133,32,204,1,144,208},{0xE8F81F6C,0xB22EA7A1,0x8B04E159}),__cc20d({234,29,10,207,12},{0xE527507C,0x36433E53,0xD0A1A699}),10,1000,Config.rageDistance,{unit=__cc20d({202,188,104,90,234,67},{0xA9F10055,0x3E58CF6F,0x0B839E68}),step=10,onChange=function(v)Config.rageDistance=v end})
U.slider(auto,__cc20d({119,246,118,243,178,232,29,71,237,8,73,100,202,18,92},{0x30576F30,0x55424375,0xC1210CED}),__cc20d({179,123,255,5,193,10,19,218,212,13},{0x466C08E2,0x83604008,0x876EE7A6}),30,500,Config.rageDelay,{unit=__cc20d({200,11,247},{0xD862A18C,0x8E63E362,0x4FEF9EE4}),step=10,onChange=function(v)Config.rageDelay=v end})
U.slider(auto,__cc20d({215,65,164,74,184,100,20,241,73,203,160,169,223,181},{0x2B206FF1,0xD26227B0,0xA935ED03}),__cc20d({173,231,209,25,91,133,161,225,35,6},{0xB0C4BB33,0x1DF138F8,0xA5455F31}),10,100,Config.rageSnap,{unit=__cc20d({53},{0xFA21C3E9,0xA3CAFEE2,0xABDC86BD}),step=5,onChange=function(v)Config.rageSnap=v end})
U.slider(auto,__cc20d({146,178,188,103,27,47,46,79,176,119,147,249,203},{0xF632F855,0x2C4F4ECA,0x0D90FEDE}),__cc20d({76,86,181,125,59,142,68,212,103,235,87,180,38,46},{0xCC62F39B,0x22A535A7,0x24280351}),2,60,Config.rageTolerance,{unit=__cc20d({187,95,102},{0x2DCE9939,0x72CDA4B6,0x5461ED25}),onChange=function(v)Config.rageTolerance=v end})
end
do
local espc=U.card(espRoot,__cc20d({175,46,64},{0x90ACDE46,0x6EC5AE0B,0x1DED5ADA}))
U.checkbox(espc,__cc20d({173,250,172,161,126,114,243,58,249,34,28},{0xC102C04B,0xDBB33C7E,0x05326521}),__cc20d({198,199,73,98,83,186,42},{0x51B90327,0x173A4199,0x6ECCDEFE}),Config.espEnabled,{onChange=function(v)Config.espEnabled=v end})
U.checkbox(espc,__cc20d({250,182,157,157,121,239,68,119,180},{0x0C626D0B,0xADF8EE0E,0x6D074F06}),__cc20d({155,148,7,243,156},{0x9226F646,0x38A9B529,0x771532A1}),Config.espBoxes,{onChange=function(v)Config.espBoxes=v end})
U.checkbox(espc,__cc20d({163,232,203,137,44,204,59,227,202},{0x09701EF7,0x09E1B0D6,0x6E295735}),__cc20d({96,31,169,249,182},{0x6D2A148D,0x21154A95,0x08EC2223}),Config.espNames,{onChange=function(v)Config.espNames=v end})
U.checkbox(espc,__cc20d({200,15,167,202,173,68,218,108,128,178},{0xC36F5706,0xD021BF6B,0x09A2466E}),__cc20d({91,49,144,114,21,86},{0xB0FBA21C,0x94F3EB93,0xC74027D2}),Config.espHealth,{onChange=function(v)Config.espHealth=v end})
U.checkbox(espc,__cc20d({179,31,101,231,85,217,172,45,55,143,86,170},{0x28472EDE,0x53523637,0x11CE6C3E}),__cc20d({145,95,50,142,76,206,15,72},{0x2E118717,0x46DFDD5F,0xB35D99C5}),Config.espDistanceText,{onChange=function(v)Config.espDistanceText=v end})
U.checkbox(espc,__cc20d({124,6,37,225,93,177,87,138,4,213,83},{0x6C5195FE,0x720473FE,0xF0DE6934}),__cc20d({181,74,254,248,43,214,223},{0x63DAF50A,0x3E53961E,0x3EC2F8B1}),Config.espTracers,{onChange=function(v)Config.espTracers=v end})
U.checkbox(espc,__cc20d({23,52,25,35,141,157,151,205,154,213,209,184},{0x07F78F82,0x7660C2AB,0x5D96581B}),__cc20d({42,193,127,107,203,79,100,89,143,173,152,106,103,71},{0x04F6A689,0xF7AD0E9C,0x20A2DF9B}),Config.espHideTeam,{onChange=function(v)Config.espHideTeam=v end})
U.dropdown(espc,__cc20d({14,15,59,63,100,172,78,31,92},{0x479FCDA6,0x6FBC1D5F,0x539F3C95}),__cc20d({137,51,178,108,27},{0xC630A07C,0x914B602E,0xABDCD2D6}),ESP_COLOR_NAMES,Config.espColor,{onChange=function(v)Config.espColor=v end})
U.slider(espc,__cc20d({12,120,22,62,219,126,250,5},{0x00F8306A,0xF86570B9,0x2B86A86E}),__cc20d({105,188,188,223,82,122,181,6},{0xD3440AB8,0xCA54E2E9,0x3010B12F}),50,3000,Config.espDistance,{unit=__cc20d({22,172,63,174,178,188},{0xD63CEAA1,0xAFC7286F,0x817863B7}),step=50,onChange=function(v)Config.espDistance=v end})
local chams=U.card(espRoot,__cc20d({48,155,101,115,39},{0xB7DA54B8,0x0463C0C5,0xDB011CE3}))
U.checkbox(chams,__cc20d({63,246,140,0,206,187,155,47,202,115,35,89,126},{0xDA83DDA6,0x0362620F,0xA2097975}),__cc20d({206,88,103,211,87,234,136},{0x1C832C8C,0x2EEF2380,0xF34EE924}),Config.chamsEnabled,{onChange=function(v)Config.chamsEnabled=v end})
U.checkbox(chams,__cc20d({249,49,86,136,242,13,69,196,162,47,88,185,131,206},{0xFAA76E1F,0xEF45A2EE,0xA8B171B3}),__cc20d({35,250,72,20,16,24,10,163,137,248,227,195,59,150},{0x3D80BE7D,0x6E5AFF76,0xF41BC54F}),Config.chamsHideTeam,{onChange=function(v)Config.chamsHideTeam=v end})
U.checkbox(chams,__cc20d({200,21,74,19,187,60,234,42,88,56,6,36,233,123,42,84,103,90},{0x5EA5A3CC,0xBCE347A5,0xA659AE87}),__cc20d({77,222,238,200,112,2,231,254,86,152,97,43,38},{0xC7F41FC1,0xACC183D5,0x43E3626A}),Config.chamsThroughWalls,{onChange=function(v)Config.chamsThroughWalls=v end})
U.checkbox(chams,__cc20d({159,89,56,116,14,234,210,204,213,124,87,110,66},{0x96910112,0x2DBBFAB5,0x8F67F555}),__cc20d({5,126,41,197,101,39,62},{0x7A701EB8,0x615A8032,0xC7F51442}),Config.chamsOutline,{onChange=function(v)Config.chamsOutline=v end})
U.checkbox(chams,__cc20d({150,108,192,36,134,148,56,106,165,171,191,57,140,106},{0x09070A6A,0x463119D7,0x1B79BD33}),__cc20d({180,10,199,212,18,103,58,100,253,61,39,71,150,174,73,41,54,178,192,161,9,164,195,223,181,222,14},{0xAF57DF02,0x60AB5E97,0xFA6B0BA4}),Config.chamsShowSelf,{onChange=function(v)Config.chamsShowSelf=v end})
U.slider(chams,__cc20d({138,206,179,207,84,205,227,84,121},{0xD7BAF756,0xEFF1C52E,0xFA6434AF}),__cc20d({251,151,180},{0xA5DD54AA,0x97EBACB2,0x08DE3EBE}),0,255,Config.chamsRed,{step=5,onChange=function(v)Config.chamsRed=v end})
U.slider(chams,__cc20d({114,170,176,179,203,137,22,174,234,84,79},{0x70D15F71,0xDCA01823,0x0F70A525}),__cc20d({100,214,214,25,217},{0xD39633D7,0x072B64FC,0xB2A866F0}),0,255,Config.chamsGreen,{step=5,onChange=function(v)Config.chamsGreen=v end})
U.slider(chams,__cc20d({83,99,22,71,140,17,85,35,28,148},{0x299BF3A3,0x17D51444,0xED683BB2}),__cc20d({119,153,54,64},{0x23125580,0x59B95F0B,0xCFC0418F}),0,255,Config.chamsBlue,{step=5,onChange=function(v)Config.chamsBlue=v end})
U.slider(chams,__cc20d({50,97,197,223,29,238,114,18,4,84},{0x3A3B3E83,0x276D24A9,0x129DCD12}),__cc20d({237,61,253,154,180,168,255,96,59,239,80,124,36,125,47,254,226},{0xD0047D27,0x13FC15EE,0x7ECFC2EB}),0,1,Config.chamsFillTransparency,{step=0.05,format=function(v)return string.format(__cc20d({117,99,14,129},{0x106C8C33,0xF4436E6F,0x267AA285}),v)end,onChange=function(v)Config.chamsFillTransparency=v end})
U.slider(chams,__cc20d({77,132,148,30,167,150,253,207,97,243,55,16,194,159,14,13,28,86},{0x7ADE2C64,0x5D8AC6E3,0x659ED4D2}),__cc20d({240,215,52,99,111,184,126,166,99,70,191,15,102,209,4,122,21,246,119,212},{0x3AB28BCB,0xFF22C296,0x30DAB3F0}),0,1,Config.chamsOutlineTransparency,{step=0.05,format=function(v)return string.format(__cc20d({7,227,13,11},{0x88640C1C,0x555C9737,0x511816B3}),v)end,onChange=function(v)Config.chamsOutlineTransparency=v end})
U.slider(chams,__cc20d({75,136,32,178,199,40,196,73,237,153},{0xE09ED646,0xC6C5143E,0x6FBC1C1B}),__cc20d({58,147,176,186,84,65,173,188},{0x23288442,0x0AB8500F,0xEEBF633C}),50,3000,Config.chamsDistance,{unit=__cc20d({150,249,11,231,90,163},{0xE3796CA5,0x931E759C,0xCDECE95A}),step=50,onChange=function(v)Config.chamsDistance=v end})
end
do
local light=U.card(worldRoot,__cc20d({9,133,79,136,128,106,239,252},{0xCED89454,0x76B608E2,0x9AD15F1A}))
U.checkbox(light,__cc20d({148,95,4,180,196,31,48,229},{0xF6950764,0x694EEBE0,0xE1D278BE}),__cc20d({55,215,227,15,165,3,68,5,243,170},{0x3E09C2E0,0x28FDEE41,0x09A384D4}),Config.fbEnabled,{onChange=function(v)Config.fbEnabled=v end})
U.checkbox(light,__cc20d({37,242,170,251,148,95,57,150,21,182,130},{0xA563C898,0x8160512E,0xDB71A646}),__cc20d({176,67,122,113,55,80,13,42,90,164,129,42,55},{0xA3CEFFB3,0x75BB14F6,0xEC516D1D}),Config.fbDaytime,{onChange=function(v)Config.fbDaytime=v end})
U.checkbox(light,__cc20d({152,86,22,86,139,59,113,90,183,132,190,35,88,94,140,32},{0x2665CE02,0xBFBD56D2,0x53D2C209}),__cc20d({214,246,185,237,1,12,41,195,10,47,202,220,145,22},{0x3E0D0243,0x5B6B7A14,0x3A50D1C7}),Config.fbNoShadows,{onChange=function(v)Config.fbNoShadows=v end})
U.checkbox(light,__cc20d({90,130,247,10,202,213,49,145,104,147,3,131,144},{0x305ED243,0xE29858D6,0x16955012}),__cc20d({6,108,45,121,50,102,227,159,90,138},{0x892CFBB8,0x62A1BBEB,0xC705C76F}),Config.fbNoFog,{onChange=function(v)Config.fbNoFog=v end})
U.slider(light,__cc20d({136,174,145,75,66,213,240,46,201,48,52,187,150,222},{0xE7839C34,0x032157F8,0xF9860CAE}),__cc20d({240,146,118,229,72,13,146,21,148,39},{0x60362CC8,0xF2113992,0x0F90F2C6}),0,5,Config.fbBrightness,{step=0.25,format=function(v)return string.format(__cc20d({78,229,226,171},{0x05D01132,0xF334FBAD,0xC9AC9E3A}),v)end,onChange=function(v)Config.fbBrightness=v end})
local move=U.card(worldRoot,__cc20d({184,158,17,139,237,171,26,150},{0x4CE61742,0x65D5930F,0x351E8DF9}))
local tpSet=select(1,U.checkbox(move,__cc20d({34,142,40,211,101,9,66,214},{0x97512CE0,0xF224A3B8,0xC54CCE19}),__cc20d({141,247,20,135,126,85,151,8,243,247,182,129},{0xFBDEEBED,0x9C3556E8,0x86EF9472}),Config.thirdPersonEnabled,{onChange=function(v)Config.thirdPersonEnabled=v end}))
thirdPersonCheckbox={get=function()return Config.thirdPersonEnabled end,set=tpSet}
U.keyfield(move,__cc20d({188,152,5,36,172,120,204,178,130,100,57,39},{0xAD1A936A,0x55262F1C,0x8D4F0BC3}),__cc20d({10,18,25,1,186,114,240,47,54,24,37,158,139,186,122,24},{0x5158F30B,0x7723B28C,0xB843B3DD}),Config.thirdPersonBind,{onChange=function(v)Config.thirdPersonBind=v end})
U.checkbox(move,__cc20d({134,136,235,82,216,100,237,224,60,130,123,18},{0xF880A595,0x44738B56,0x3FB8D5A8}),__cc20d({190,27,161,108,148,3,139,171,92,26,46,110},{0x1A1BC555,0x30080AFD,0x33842AC6}),Config.thirdPersonShowBody,{onChange=function(v)Config.thirdPersonShowBody=v end})
U.slider(move,__cc20d({4,110,199,121,177,170,45,79,137,208,35,163},{0x7A730C36,0xF89E1B83,0xA4B4E373}),__cc20d({126,134,68,123,131,244,14,102,185,94,200,156,182,189,156},{0xF454D9B6,0x6FF16AAA,0x7A5E6052}),2,40,Config.thirdPersonDistance,{unit=__cc20d({125,48,21,37,15,141},{0x1C882E67,0x8B080529,0x87FFA2D1}),onChange=function(v)Config.thirdPersonDistance=v end})
U.checkbox(move,__cc20d({159,7,45,70,68,253,182,174,166,174,192},{0x65B582F6,0xC8861622,0x35338114}),__cc20d({179,197,94,203,135},{0xDA5EF405,0x5B6A6CA4,0x0A24F624}),Config.speedEnabled,{onChange=function(v)Config.speedEnabled=v end})
U.slider(move,__cc20d({166,44,182,89,117,224,252,99,94,198,197,32,188,72},{0xCE439181,0xD67F5B1F,0x06410F73}),__cc20d({78,3,213,193,193,118,108,125,199,88},{0x8DA085D6,0x0D401976,0x5BAE5620}),16,100,Config.speedValue,{unit=__cc20d({148,255,111,29,118,92,4,201},{0xD4CFADB3,0x84F325DC,0xA7E62E15}),onChange=function(v)Config.speedValue=v end})
U.checkbox(move,__cc20d({172,114,216,39,242,4,61,173,200,105,207,198,54,163,214,22},{0x65765E6E,0xD7D3C6DF,0x54321A8B}),__cc20d({64,220,74,98,139,223,165,134,76,27,133,177,193,114,102,32,80,229,67,254,57,52,36,207,151},{0xECB30680,0xE9F6B2EB,0xB550A12F}),Config.speedAccelEnabled,{onChange=function(v)Config.speedAccelEnabled=v end})
U.slider(move,__cc20d({233,169,120,113,214,130,237,16,110,223,118,31,157,255,110,237,172,181,217,248},{0x3305E985,0xEB3A8926,0x46952558}),__cc20d({12,37,34,45,68,226,208,177,56,101},{0x568A9434,0x1D8D6BB0,0x553DD0B2}),5,200,Config.speedAccelRate,{step=5,onChange=function(v)Config.speedAccelRate=v end})
U.checkbox(move,__cc20d({51,9,229,93,161,39,122,220,46,245,78,25,155},{0x83C87953,0x8E6E7017,0x3366FEC3}),__cc20d({62,253,84,1,212,120,168,246,7,40,149},{0x4DA1E090,0x7D411FED,0x4D7A72D6}),Config.lowGravityEnabled,{onChange=function(v)Config.lowGravityEnabled=v end})
U.slider(move,__cc20d({248,196,198,58,90,32,64,177,122,202,20,122,182,162,188,245,6,185},{0xB8012931,0xA04C01A8,0x583A491E}),__cc20d({47,243,209,115,79,53,123,81,27,234,129,233,120},{0xEC4B385A,0x00D5E233,0x0118F346}),0.1,1,Config.lowGravityScale,{step=0.05,format=function(v)return string.format(__cc20d({193,254,175,203,162},{0x66D96C20,0xC94475C3,0x44639CA8}),v)end,onChange=function(v)Config.lowGravityScale=v end})
U.checkbox(move,__cc20d({125,203,134,247,203,194,172,32,147,110},{0x4C752628,0x0ACE25E0,0x60E9C73A}),__cc20d({177,176,188,227,59,166,14,176,236,4,19,179,196,39,61,15},{0xF28E08B4,0x429303D5,0xCD90F0B4}),Config.bhopEnabled,{onChange=function(v)Config.bhopEnabled=v end})
local flySet=U.checkbox(move,__cc20d({102,248,212,167,195,59,188,73,13},{0xBD9B9071,0x60F524F1,0xF187351B}),__cc20d({111,135,130},{0x605A9B71,0xABEC1B86,0x140CE2CB}),Config.flyEnabled,{onChange=function(v)Config.flyEnabled=v end})
flyCheckbox={get=function()return Config.flyEnabled end,set=flySet}
U.keyfield(move,__cc20d({79,157,20,161,145,161,119,109,165,105,240,119,126},{0xCB1522A5,0x8F5EDF9B,0x65838624}),__cc20d({222,213,50,226,209,137,20},{0x7E05F76B,0x37C531B6,0xE3F4AD8B}),Config.flyBind,{onChange=function(v)Config.flyBind=v end})
U.slider(move,__cc20d({143,112,87,208,158,70,92,44,235,124,115,160,108,174},{0x98B0667C,0x7237DC10,0xC56376BC}),__cc20d({179,25,101,79,211,227,85,248,97},{0xFDE0A046,0x1AAA1526,0xC1FAEBAA}),10,200,Config.flySpeed,{unit=__cc20d({66,243,132,196,159,76,143,252},{0x3D75B1B9,0x53120205,0x65008B85}),onChange=function(v)Config.flySpeed=v end})
end
do
luaNameBox=U.textbox(luaRoot,selectedLua,__cc20d({108,127,71,72,149,124,222,124,49,106,151},{0x457DB8D6,0x5CD5045E,0x8B1D44C1}))
luaNameBox.FocusLost:Connect(function()
selectedLua=L.sanitizeName(luaNameBox.Text)
luaNameBox.Text=selectedLua
end)
U.button(luaRoot,__cc20d({23,217,156,22,26,185,15,76,63,63,97,153,61,157,223,241,38,30,43,96,123},{0xE43FD029,0xC4FD28C3,0x2856C20A}),false).MouseButton1Click:Connect(function()
local names=L.listLuaScripts()
if#names==0 then
L.setLuaStatus(__cc20d({247,192,37,158,179,172,115,127,247,37,228,236,238,198,107,4,99,98},{0x34860094,0x941510BA,0xD05A75BF}))
return
end
local index=table.find(names,selectedLua)or 0
selectedLua=names[index%#names+1]
luaNameBox.Text=selectedLua
L.setLuaStatus(__cc20d({22,12,176,195,224,34,133,39,165,85},{0x5D335E8D,0x94015EA0,0x5C72B852})..selectedLua)
end)
luaCodeBox=U.codebox(luaRoot,__cc20d({},{0x1FFF4241,0xF7322FA6,0x31054BE9}),140)
local row=U.new(__cc20d({4,204,146,30,223},{0xA96388F2,0xD7023DC7,0xE6691044}),{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1},luaRoot)
U.order(row)
U.new(__cc20d({31,254,102,136,166,164,88,148,92,250,104,241},{0xE576938D,0xEADF3055,0x3C928A93}),{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},row)
U.button(row,__cc20d({21,188,65},{0x8A92FF1C,0x56CDFE65,0x16C2573F}),true,UDim2.new(0.25,-5,1,0)).MouseButton1Click:Connect(L.runLua)
U.button(row,__cc20d({89,154,255,3},{0xB8E2CEB3,0x1648DA0B,0x36029E11}),false,UDim2.new(0.25,-5,1,0)).MouseButton1Click:Connect(L.saveLua)
U.button(row,__cc20d({204,37,185,133},{0x0D9E4CF0,0x9D883EF2,0xA1E3DD5F}),false,UDim2.new(0.25,-5,1,0)).MouseButton1Click:Connect(L.loadLua)
U.button(row,__cc20d({236,32,26,9,199,147},{0x6579FA67,0xC4064E61,0x987458EA}),false,UDim2.new(0.25,-5,1,0)).MouseButton1Click:Connect(L.deleteLua)
U.checkbox(luaRoot,__cc20d({212,102,206,236,73,38,80,31,160,47,87},{0xB8EC2C71,0xEBF4C830,0x469EB9EC}),__cc20d({95,7,188,46,107,227,181,255,238,2,226,30,80,248,79,103,182,12,55,80,109,16,123,8,162,185,190},{0x8601DFA4,0xF5C0F460,0xE6954E45}),Config.luaAutorunEnabled,{onChange=function(v)Config.luaAutorunEnabled=v end})
U.button(luaRoot,__cc20d({247,253,94,35,106,116,139,82,142,100,22,229,160,149,106,85,0,165,125,234,98,116,147},{0x2862F689,0x1BB8AF30,0xB538BF6F}),false).MouseButton1Click:Connect(function()
Config.luaAutorunName=selectedLua
L.setLuaStatus(__cc20d({147,190,108,53,25,99,68,235,240,251,166,165,100},{0x4A978ADC,0xE6475451,0x9224288F})..selectedLua)
end)
luaStatusLabel=U.sublabel(luaRoot,luaMessage)
end
do
U.slider(timingRoot,__cc20d({19,125,78,62,76,23,241,95,0,58,225,154,224,13,167},{0xB4373BCE,0xBE7DB9E4,0xEBCC8695}),__cc20d({93,86,238,68,230,107,101,197,189,70,207,188,8,87},{0xE7F6B8BB,0x262CB243,0x0E0312C3}),0,300,Config.reactionDelay,{unit=__cc20d({139,196,171},{0x6FB62EB1,0xCB2C7493,0x9BA84260}),step=5,onChange=function(v)Config.reactionDelay=v end})
U.slider(timingRoot,__cc20d({221,166,211,167,222,174,116,159,143,127,26,220,224,254,211},{0xAE6CCFB2,0xC07C138A,0x61353784}),__cc20d({114,56,17,70,39,192,84,195,205,166,186,241,182,194},{0x19B60211,0xDFF63B4B,0x655E6E5E}),20,500,Config.clickCooldown,{unit=__cc20d({214,75,228},{0x6F262FB6,0xDB724A9F,0x74BC0719}),step=10,onChange=function(v)Config.clickCooldown=v end})
U.slider(timingRoot,__cc20d({87,170,111,114,168,141,45,89,146,35,146,140,95,9,19,215,194,213},{0x5560FA5A,0x0BFDB55A,0xF2C95140}),__cc20d({202,4,225,253,25,11,100,44,239,171,139,77,248,46,62,152,143,166},{0x065F30C8,0xAE960AC3,0x928D42AB}),0,500,Config.holdRelease,{unit=__cc20d({191,112,143},{0xB39EDA80,0xA9F360E3,0x6D1853E5}),step=10,onChange=function(v)Config.holdRelease=v end})
end
do
local cl,cr=U.columns(settingsRoot)
local ccard=U.card(cl,__cc20d({118,95,50,224,88,196},{0x766590EF,0x3AB216A3,0x71CDAB73}))
U.sublabel(ccard,__cc20d({111,160,83,165,149,203,62,235,52,2,79},{0x3CB109D6,0xFD689797,0x5C2099D2}))
local nameBox=U.textbox(ccard,__cc20d({220,184,231,205,7,254,234},{0x50633725,0xF00DF4BD,0x4B9830ED}))
local row1=U.new(__cc20d({7,152,41,78,151},{0xDC1C1B13,0xB0F50462,0x3921CB80}),{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1},ccard)
U.order(row1)
U.new(__cc20d({230,198,161,61,11,38,248,9,35,58,235,41},{0x7EAD330A,0x47A4AEBA,0x1E6793A2}),{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},row1)
local saveBtn=U.button(row1,__cc20d({74,244,177,137},{0x2D559E01,0x67B6F1A3,0x31A6A558}),true,UDim2.new(0.5,-4,1,0))
local loadBtn=U.button(row1,__cc20d({48,195,135,18},{0x59737FBB,0x2084F93B,0x2DD5B7B7}),false,UDim2.new(0.5,-4,1,0))
saveBtn.LayoutOrder=1
loadBtn.LayoutOrder=2
local row2=U.new(__cc20d({69,121,160,120,241},{0x30F08769,0xA4B487F3,0xA8B74BCB}),{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1},ccard)
U.order(row2)
U.new(__cc20d({223,78,39,184,210,150,187,229,99,165,100,122},{0x0CEA17BD,0xD8B0D3C9,0xE28811A0}),{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},row2)
local delBtn=U.button(row2,__cc20d({161,18,185,131,50,80},{0x985CD4E2,0x34B9335B,0xB5EBDFC9}),false,UDim2.new(0.5,-4,1,0))
local resetBtn=U.button(row2,__cc20d({175,50,219,170,22},{0xA6E724C1,0x8F8DCA2B,0x2A1EF9F7}),false,UDim2.new(0.5,-4,1,0))
delBtn.LayoutOrder=1
resetBtn.LayoutOrder=2
local unloadBtn=U.button(ccard,__cc20d({120,198,2,65,8,228},{0x944725DD,0x8CC7BB98,0x8BEA0C72}),false,UDim2.new(1,0,0,26))
local status=U.new(__cc20d({113,58,183,130,149,149,79,203,110},{0xC3B110BF,0x4497ACFE,0x9C9DB74B}),{
Text=__cc20d({147,24,131,36,129},{0x49F4644B,0xAA3206DE,0xD9FE88C9}),Font=F.reg,TextSize=11,TextColor3=T.sub,
BackgroundTransparency=1,Size=UDim2.new(1,0,0,14),
TextXAlignment=Enum.TextXAlignment.Left,
},ccard)
U.order(status)
local function cfgName()
local n=nameBox.Text
if n==__cc20d({},{0xE43EFD31,0x48F29BF3,0xBF26C4B4})then n=__cc20d({75,147,160,248,13,253,186},{0x1507312F,0x03B62320,0xE25DAD29})end
return n
end
saveBtn.MouseButton1Click:Connect(function()
local ok,msg=L.saveConfig(cfgName())
status.Text=msg
status.TextColor3=ok and T.green or T.accent
end)
loadBtn.MouseButton1Click:Connect(function()
local ok,msg=L.loadConfigFile(cfgName())
status.Text=msg
status.TextColor3=ok and T.green or T.accent
end)
delBtn.MouseButton1Click:Connect(function()
local ok,msg=L.deleteConfigFile(cfgName())
status.Text=msg
status.TextColor3=ok and T.green or T.accent
end)
resetBtn.MouseButton1Click:Connect(function()
for id,setter in pairs(Setters)do pcall(setter,Defaults[id])end
L.stopHold()
held=false
aimHeld=false
assistTarget=nil
status.Text=__cc20d({250,4,15,99,249},{0x2EEFE8B3,0x5D7BBD56,0x9DD7A098})
status.TextColor3=T.sub
end)
unloadBtn.MouseButton1Click:Connect(function()
TriggerBot.detach()
end)
local help=U.card(cr,__cc20d({225,88,74,178},{0x542D5623,0x466577AF,0x21603F73}))
for _,txt in ipairs({
__cc20d({130,162,201,44,111,167,24,41,79,34,33,116,135,184,167,112,222,116,37,231,139,1,158,204,253,255,123,107},{0x90C8ABEF,0x47963B1E,0x3F11E623}),
__cc20d({187,219,199,54,221,53,254,157,163,254,19,197,118,39,111,4,244,255,207,17,185,27,243,105,208,143,58,231,28,114,212,252,119,184,211,54,202,182,24,252,45,69,132,183,79,82,66,41,58,165,192,6,21},{0x79F14DFE,0x2EAB2CA1,0x72325062}),
__cc20d({2,209,184,146,13,131,224,175,59,211,145,123,118,17,174,129,220,143,181,129,186,227,101,77,164,217,8,85,131,89,188,215,219,28,184,20,140,217,229,186,241,251,255,236},{0xF4B0BC73,0x3C171418,0xE9819BF7}),
__cc20d({108,219,64,22,62,213,125,82,179,64,96,135,45,65,97,186,2,83,4,52,179,238,156,70,192,150,38,178,182,141,216,200,12,56,51,103,118,212,191,179,249,193,218,50,198,170,18,123,64,40,142},{0x5358BA17,0xAD6AA9AC,0x8FDE7A21}),
__cc20d({105,130,42,189,131,7,157,179,224,151,63,169,182,207,91,241,229,10,25,202,160,63,243,197,156,59,86,209,151,24,100,153,214,207,239,125,60},{0x8C4436CD,0x84216506,0x6589314D}),
})do
U.sublabel(help,txt)
end
end
L.clearDrawings=function()
for player in pairs(chamObjects)do L.removeChams(player)end
for player in pairs(espObjects)do L.removeEsp(player)end
L.clearBulletTracers()
if fovCircle then
pcall(function()fovCircle:Remove()end)
fovCircle=nil
end
if assistCircle then
pcall(function()assistCircle:Remove()end)
assistCircle=nil
end
end
function TriggerBot.detach()
L.stopHold()
pcall(runService.UnbindFromRenderStep,runService,UPDATE_BIND_NAME)
pcall(runService.UnbindFromRenderStep,runService,SPIN_BIND_NAME)
pcall(runService.UnbindFromRenderStep,runService,CAMERA_RESTORE_BIND_NAME)
pcall(runService.UnbindFromRenderStep,runService,CAMERA_APPLY_BIND_NAME)
L.restoreSpin()
L.restoreCamera()
L.restoreBody()
for _,connection in ipairs(connections)do connection:Disconnect()end
table.clear(connections)
L.clearDrawings()
L.restoreLighting()
if savedGravity then
workspaceService.Gravity=savedGravity
savedGravity=nil
end
if window then
window:destroy()
window=nil
end
statusLabel=nil
thirdPersonCheckbox=nil
flyCheckbox=nil
luaNameBox=nil
luaCodeBox=nil
luaStatusLabel=nil
assistTarget=nil
rageEngaged=false
silentTarget=nil
shared.TriggerBotNamecall=nil
shared.TriggerBot=nil
end
function TriggerBot.init()
fovCircle=L.newDrawing(__cc20d({250,227,133,9,62,106},{0x9CE8EFED,0x38D41857,0x561917F3}),{Thickness=1,NumSides=64,Filled=false,Color=Color3.new(1,1,1),Transparency=1,Visible=false})
assistCircle=L.newDrawing(__cc20d({84,64,184,110,122,75},{0xF1556B97,0x6E097254,0x7260940E}),{Thickness=1,NumSides=64,Filled=false,Color=Color3.fromRGB(255,220,70),Transparency=1,Visible=false})
pcall(runService.UnbindFromRenderStep,runService,UPDATE_BIND_NAME)
pcall(runService.UnbindFromRenderStep,runService,SPIN_BIND_NAME)
pcall(runService.UnbindFromRenderStep,runService,CAMERA_RESTORE_BIND_NAME)
pcall(runService.UnbindFromRenderStep,runService,CAMERA_APPLY_BIND_NAME)
local function bindStep(name,priority,callback)
local success,bindError=pcall(runService.BindToRenderStep,runService,name,priority,callback)
if not success then warn(__cc20d({82,224,177,84,243,95,106,62,97,236,137,171,151,127,70},{0x59108E84,0x9CCA4690,0xCF79F480})..name..__cc20d({102,55},{0xBBDE8F06,0xADBC6A98,0xF2D2BF09})..tostring(bindError))end
return success
end
bindStep(SPIN_BIND_NAME,RESTORE_RENDER_PRIORITY,L.restoreSpin)
bindStep(CAMERA_RESTORE_BIND_NAME,RESTORE_RENDER_PRIORITY,L.restoreCamera)
if not bindStep(UPDATE_BIND_NAME,UPDATE_RENDER_PRIORITY,L.onRenderStep)then
table.insert(connections,runService.RenderStepped:Connect(L.onRenderStep))
end
bindStep(CAMERA_APPLY_BIND_NAME,CAMERA_APPLY_PRIORITY,L.applyCamera)
shared.TriggerBotNamecall=L.onNamecall
table.insert(connections,runService.Stepped:Connect(L.restoreCamera))
table.insert(connections,runService.Heartbeat:Connect(L.applySpin))
table.insert(connections,userInputService.InputBegan:Connect(L.onInputBegan))
table.insert(connections,userInputService.InputEnded:Connect(L.onInputEnded))
table.insert(connections,playersService.PlayerRemoving:Connect(L.removeEsp))
table.insert(connections,playersService.PlayerRemoving:Connect(L.removeChams))
if Config.luaAutorunEnabled and Config.luaAutorunName~=__cc20d({},{0xDF7ACED4,0x415FB300,0xA689BB93})then
task.spawn(L.runLuaFile,Config.luaAutorunName)
end
print(__cc20d({77,11,250,56,172,7,55,191,233,227,143,127,251,254,4,143,125},{0x172F4513,0xDEFE695B,0x14B6B4D5}))
end
local function onInitializeError(error)
warn(__cc20d({255,87,212,198,130,36,248,48,135,227,108,143,167,97,104,244,188,45,158,114,75},{0xDAEC7322,0x61CDD3D5,0x9C4306CB}))
warn(error)
warn(debug.traceback())
TriggerBot.detach()
end
if shared.TriggerBot then
pcall(shared.TriggerBot.detach)
end
shared.TriggerBot=TriggerBot
xpcall(TriggerBot.init,onInitializeError)
