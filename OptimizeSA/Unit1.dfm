object Form1: TForm1
  Left = 192
  Top = 128
  Cursor = crCross
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Optimize 2001'
  ClientHeight = 563
  ClientWidth = 772
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 344
    Width = 425
    Height = 209
    Cursor = crCross
    BorderStyle = bsNone
    Color = 722952
    Font.Charset = ANSI_CHARSET
    Font.Color = clSilver
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    Lines.Strings = (
      'What is Optimize ?'
      '----------------------'
      ''
      '- Optimize is South Africa'#39's own Scene Party and Compo.'
      
        '- It gives South African sceners a chance to meet each other and' +
        ' enter for the '
      'various competition categories. '
      
        '- The scene consists of programmers, musicians and artists, who ' +
        'enter for '
      
        'competition categories like hand drawn art, games, demos, tracke' +
        'd music, etc. '
      ''
      ''
      'Optimize stretch over 2 days.'
      '-----------------------------------'
      ''
      
        '- On day one some people arrive, set up their PCs, chat, or make' +
        ' some finishing '
      
        'touches to their entries till late. We watch some videos, share ' +
        'some files, etc. '
      
        '- On the second day the rest arrives and we get everything ready' +
        ' for the voting. In '
      
        'the afternoon every entry is collected and previewing of the ent' +
        'ries start. Everyone '
      
        'get a chance to vote for the best entries in the category; after' +
        ' which all votes are '
      'collected, counted and the winners announced '
      ''
      ''
      'What must I bring?'
      '-----------------------'
      ''
      
        '- If you want to arrive on day one you will need a sleeping bag ' +
        'if you plan on '
      'sleeping over '
      
        '- You will need some food, we will have a braai. There will be d' +
        'rinks for sale, '
      'alcoholic and non-alcoholic '
      '- Your entry(s) for the competition '
      
        '- Your PC (optional, it might happen that your demo/game does no' +
        't want to execute '
      'on the test machine) '
      
        '- Your invitation card (e-mailed to you a day or so after you re' +
        'gistered) '
      '- Entry fee (see registration page) '
      ''
      ''
      'When, where, how, what'
      '--------------------------------'
      ''
      '- Date: Friday and Saturday. 23, 24 November.'
      
        '- Time: Arrive anytime from 10h00 on Friday; voting starts at 15' +
        'h00 on Saturday.'
      '- Place: Midrand'
      ''
      ''
      'Other info'
      '------------'
      ''
      '- Bring some network cable (UTP) and hubs (10Mbsp) if you have '
      '- Bring electrical extension cable and plugs '
      '- There is a swimming pool '
      '- Bring your scrap CDs for the Frisbee throw '
      ''
      ''
      'Hardware available at party'
      '-----------------------------------'
      ''
      '- Big screen TV '
      '- Sound system with DVD/CD, and tape '
      '- VCR '
      '- Powerful PC '
      '- If you got something usefull contact me '
      ''
      ''
      'How will entries be previewed ?'
      '---------------------------------------'
      
        '- There will be a 800MHz AMD Thunderbird with GeForce-2 GTS mach' +
        'ine that will '
      
        'playback demos, games, etc on a big TV screen. (If anyone can pr' +
        'ovide me with a '
      
        'proxy (projector) we can use that for previewing demos, etc with' +
        ' fine text '
      
        '(unreadable on TV screen). The test machine only has Windows ope' +
        'rating system '
      
        '(98/Me/NT). People attending the party will watch the demos, etc' +
        ' being played back '
      
        'and after that vote on the best in the catagory by giving it a 1' +
        'st, 2nd, 3rd place, etc. '
      
        'Depending on the number of entries for that catagorie a score wi' +
        'll be calculated.'
      '- The score is calculated this way:'
      '- Catagory 1: 5 entries'
      '- Thus: 1st = 5points, 2nd = 4points, 3rd = 3points, etc.'
      
        '- So: If an item get a vote for first place from someone it rece' +
        'ive 5 points, and if it '
      
        'get a vote for 3rd place it gets 3 points, etc. All points are a' +
        'dded and 1st, 2nd, etc '
      'revieled.'
      ''
      ''
      'General rules'
      '----------------'
      ''
      '- Only people attending the party will be allowed to vote '
      
        '- Entries must support a resolution of 800x600 or 640x480 (16/32' +
        'bit) for playback '
      
        'on TV screen (except where mentioned other) (Notice that you can' +
        ' choose to '
      
        'playback the entry at either 640x480 or 800x600, to best suite t' +
        'he entry) '
      ''
      ''
      'Competition Categories'
      '=================='
      ''
      'Intros & Demos'
      '-------------------'
      ''
      '4kb intro'
      '----------'
      ''
      
        '- The intro executable and all supporting data must be no more t' +
        'han 4kb in size '
      '- The intro can use another resolution than 640x480 / 800x600 '
      '- Playback in DOS or Windows '
      ''
      ''
      '64kb intro'
      '------------'
      ''
      
        '- The eatable and all supporting data must be no more than 64kb ' +
        'in size '
      '- The intro can use another resolution than 640x480 / 800x600 '
      '- Playback in DOS or Windows '
      ''
      ''
      'Megademo'
      '-------------'
      ''
      '- There is no size limit '
      
        '- Must support either or both 640x480 and/or 800x600 resolution ' +
        '(8/16/32 bit) '
      '- Must playback on Windows machine '
      
        '- Graphics: Can make use of Software, DirectX, or OpenGL API, no' +
        ' other 3rd party '
      'libraries.'
      
        '- Sound: Can make use of 3rd party libraries like FMod, Bass, Se' +
        'al, Midas, etc. '
      ''
      ''
      'Java intro'
      '------------'
      ''
      '- Playback on Windows machine '
      '- Playback at either 640x480 or 800x600 (8/16/32 bit) '
      '- Latest Netscape and Internet Explorer available for preview '
      '- Can make use of some 3rd party graphics libraries for Java'
      '- Can be any size '
      ''
      ''
      'Web intro'
      '------------'
      ''
      '- Playback on Windows machine '
      '- Latest Netscape and Internet Explorer available for preview '
      
        '- Playback at either 640x480 or 800x600 (8/16/32 bit) (800x600 h' +
        'ighest) '
      
        '- A web intro can make use of DHTM, scripting (JavaScript, VBScr' +
        'ipt) '
      '- JPG and GIF images only '
      
        '- Optional support for PHP4, MySQL servers available on test mac' +
        'hine '
      '- NO Java or Flash/Shockwave '
      '- Can be any size '
      ''
      ''
      'Game'
      '-------'
      ''
      '- You can enter a finished or unfinished game '
      
        '- No commercial work will be allowed (that is a game that has a ' +
        'publisher)'
      
        '- The game must support a resolution of either 640x480 or 800x60' +
        '0 (8/16/32bit), '
      'and support Windows 95/98/ME and/or NT/2000/XP '
      '- Can make use of ANY API (OpenGL, OpenAL, DirectX, etc) '
      '- Can make use of ANY sound library (FMod, Seal, Bass, etc)'
      '- Can be any size '
      
        '- There are two categories for games, 2D and 3D and they will be' +
        ' judged '
      
        'separately, if your not sure of the category your game fall into' +
        ' ask me at the compo. '
      ''
      ''
      '2D Game'
      '-----------'
      ''
      '- Platform games, standard ¾ view RPG, board games, etc. '
      
        '- Can still make use of APIs like OpenGL but obviously this will' +
        ' be a 2D view and no '
      '3D objects will be allowed. '
      ''
      ''
      '3D Game'
      '-----------'
      ''
      '- Use of 3D objects in game '
      '- Terrain engines, FPS, etc. '
      ''
      ''
      'Art/ Graphics/ Rendering'
      '-----------------------------------'
      ''
      
        '- Art will be previewed at either 800x600 or 640x480 at 16/32bit' +
        ' on a Windows '
      'Me/XP machine with ACDSee. '
      
        '- All ACDSee supported file formats are allowed (JPEG, GIF, BMP,' +
        ' PCX, TGA, PSD, '
      'TIF, PNG) '
      ''
      ''
      'Hand drawn art'
      '--------------------'
      ''
      '- Draw by hand and scanned '
      
        '- No changes except changing the size can be made through softwa' +
        're '
      ''
      ''
      'Photo manipulation'
      '-----------------------'
      ''
      '- Scanned photos or hand drawn art '
      '- Manipulation through software filters, etc '
      ''
      ''
      'Retraced art'
      '---------------'
      ''
      '- Ray traced '
      ''
      ''
      'PC handdrawn'
      '-------------------'
      ''
      '- No scanned photos or hand art to manipulate '
      '- Basically use of software alone to create the pic '
      ''
      ''
      'Tracked/ Open Music'
      '--------------------------'
      ''
      
        '- All music will be played back through the latest Winamp 2 (not' +
        ' Winamp 3 betas) '
      ''
      ''
      'Tracked music'
      '------------------'
      ''
      
        '- Tracked using some kind of tracking software like Protracker, ' +
        'Screamtracker, '
      'Impulsetracked, Fasttracker, Multitracked, Ultratracked, etc) '
      
        '- Can be any mod format supported by Winamp (mod, stm, s3m, it, ' +
        'xm, mtm, ult) '
      '- Make sure it plays ok in Winamp '
      ''
      ''
      'Open music'
      '--------------'
      ''
      '- Tracked, sampled, or what ever means you used to make it '
      '- Will be played through Winamp '
      '- Must be MP3 format '
      '- Make sure it plays ok in Winamp '
      ''
      ''
      'Animation'
      '-----------'
      ''
      '- Will be played at either 640x480 or 800x600, 16/32 bit '
      '- Playback on a Windows machine '
      '- Windows Media player with latest MPEG and DIVX codec '
      '- Can be a Flash/Shockwave '
      '- AVI, DivX, MPEG '
      '- Can have sound '
      '- Can be any length '
      
        '- Must be rendered or created using software, no shots from outs' +
        'ide allowed (like '
      'camcorder material) '
      ''
      ''
      'Wild'
      '------'
      ''
      
        '- Here you can enter anything you think have a chance of showing' +
        ' your creativity '
      
        '- Stuff like a video of you and your friends, or even a movie yo' +
        'u made '
      '- A cool cartoon '
      '- Playback/Preview available through VCR, DVD, CD, Tape, or PC '
      ''
      ''
      
        'If you have any further inquiries concerning any category feel f' +
        'ree to contact me at '
      'cyberblue_creations@yahoo.com heading [O2K+ Enquiry]'
      '')
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object MediaPlayer1: TMediaPlayer
    Left = 168
    Top = 32
    Width = 253
    Height = 30
    FileName = 'merit.mid'
    Visible = False
    TabOrder = 1
  end
end
