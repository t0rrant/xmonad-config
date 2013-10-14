-- xmobar config used by Manuel Torrinha
-- Author: Manuel Torrinha
-- http://github.com/t0rrant/xmonad-config

Config { font= "xft:Bitstream Vera Sans Mono:size=9:antialias=true"
       , bgColor = "black"
       , fgColor = "grey"
       , position = TopW L 95
       , lowerOnStart = True
       , commands = [ Run Weather "LPPT" ["-t","Lx: <tempC>C <skyCondition>","-L","7","-H","30","--normal","green","--high","red","--low","lightblue"] 36000
--                    , Run Network "eth0" ["-t","<dev>: <rx> | <tx>","-L","10","-H","200","--normal","green","--high","red","-S","True"] 10
                    , Run MultiCpu ["-t", "Cpu: <total0> <total1> <total2> <total3>","-L","3","-H","70","--low","yellow","--normal","green","--high","red","-w", "3"] 10
                    , Run Memory ["-t","Mem: <usedratio>%","-L","3","-H","90","--normal","green","--high","red"] 10
                    , Run Date "%a %b %_d %H:%M" "date" 10
                    , Run StdinReader
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%StdinReader% } <fc=#ee9a00>%date%</fc> { %multicpu% | %memory% | %LPPT%"
       }
