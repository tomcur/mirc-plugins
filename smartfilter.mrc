on *:START: {
  ; Called on script start. Read settings from ini and set cleanup timer.
  SET %timeout $readini(smartfilter.ini, durations, timeout)
  if (%timeout == $null) {
    SET %timeout 300
  }
  timerSMARTFILTERCLEANUP 0 300 cleanup
}

alias isIdle {
  ; Determines whether the given timestamp (in settings) counts as being idle.
  if ($1 == $null) {
    return $true
  }
  elseif ($ctime > $calc($1 + %timeout)) {
    return $true
  }
  else {
    return $false
  }
}

alias cleanup { 
  ; Cleanup the used activity timestamps.
  var %n = $var(lastTalk. $+ *,0), %var, %varVal
  while (%n >= 1) {
    %var = $gettok($var(lastTalk. $+ *,%n),2-,46)
    %varVal = %lastTalk. [ $+ [ %var ] ]
    if ($isIdle(%varVal)) {
      UNSET %lastTalk. [ $+ [ %var ] ]
    }
    dec %n
  }
}

on *:TEXT:*:#: {
  ; Called when a nick speaks in a channel. Update the activity timestamp for
  ; the given nick in the appropriate channel and network.
  SET %lastTalk. [ $+ [ $network ] $+ . $+ [ $chan ] $+ . $+ [ $nick ] ] $ctime
}

on ^*:JOIN:#: {
  ; Called when a nick joins a channel. Checks whether they were active in
  ; the given channel and network, and if not, surpresses the join message.
  if ($isIdle(%lastTalk. [ $+ [ $network ] $+ . $+ [ $chan ] $+ . $+ [ $nick ] ])) {
    HALT
  }
}

on ^*:PART:#: {
  ; Called when a nick leaves a channel. Checks whether they were active in
  ; the given channel and network, and if not, surpresses the join message.
  if ($isIdle(%lastTalk. [ $+ [ $network ] $+ . $+ [ $chan ] $+ . $+ [ $nick ] ])) {
    HALT
  }
}

on ^*:QUIT: {
  ; Called when a nick quits. For each common channel, checks whether they 
  ; were active in the given channel and network. If so: send a (custom) 
  ; quit message. Surpresses all default quit messages.
  var %i = 0, %chan
  while (%i < $comchan($nick,0)) {
    inc %i
    %chan = $comchan($nick,%i)
    if (!$isIdle(%lastTalk. [ $+ [ $network ] $+ . $+ [ %chan ] $+ . $+ [ $nick ] ])) {
      echo $colour(quit) %chan * $nick ( [ $+ [ $fulladdress ] $+ ] ) Quit ( [ $+ [ $1- ] $+ ] )
    }
  }

  HALTDEF
}

dialog smartFilter {
  ; Setup settings dialog.
  title "Smart join and part filter"
  size -1 -1 260 170
  text "Smart join and part filter v1.0 by Beskhue. The idle timeout controls after how many seconds of idling in a specific channel joins/parts of a nick will not be shown in that channel.",1,15 15 230 50
  box "Idle timeout (seconds)", 2, 15 75 230 48
  edit %timeout, 3, 20 93 220 20
  button "Ok", 4, 15 135 100 20, ok
  button "Cancel", 5, 145 135 100 20, cancel
}

alias smartfilter { 
  ; Show the settings dialog.
  if (!$dialog(smartFilter)) { 
    dialog -m smartFilter smartFilter
  } 
}

on *:dialog:smartfilter:*:*: {
  ; Called when a settings dialog event occurs.
  if ($devent == init) {
    ; Called on dialog initialization.
    did -ra $dname 3 $iif(%timeout,%timeout,-No settings-)
  }
  elseif ($devent == edit) {
    ; Called when the data was edited.
    if($did == 3)
    {
      set %timeout $did(3)
      writeini smartfilter.ini durations timeout %timeout
    }
  }
}

menu * {
  ; Add script to the context menu.
  -
  Join/part Filter
  .Settings: smartfilter
  .-
  .About: echo -at Smart join and part filter v1.0 by Beskhue. | echo -at Contact me through chat.freenode.net @ Besk. | echo -at https://github.com/Beskhue
  -
}
